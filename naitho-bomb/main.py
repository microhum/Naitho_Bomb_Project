import serial
import threading
import time
from pydub import AudioSegment
import simpleaudio as sa
from typing import TypedDict


class SoundData(TypedDict):
    path: str
    loop: bool
    audio: AudioSegment | None
    play_obj: sa.PlayObject | None
    thread: threading.Thread | None
    stop_flag: bool


class BombController:
    def __init__(self):
        self.playing = False
        self.sounds: dict[str, SoundData] = {
            "ticking": SoundData(
                path="resources/ticking2.mp3",
                loop=True,
                audio=None,
                play_obj=None,
                thread=None,
                stop_flag=False,
            ),
            "defused": SoundData(
                path="resources/defused.mp3",
                loop=False,
                audio=None,
                play_obj=None,
                thread=None,
                stop_flag=False,
            ),
            "explosion": SoundData(
                path="resources/explosion.mp3",
                loop=False,
                audio=None,
                play_obj=None,
                thread=None,
                stop_flag=False,
            ),
        }
        self.current_sound: str | None = None
        for sound_data in self.sounds.values():
            sound_data["audio"] = AudioSegment.from_mp3(sound_data["path"])

    def _play_worker(self, name: str) -> None:
        sound_data = self.sounds[name]
        sound_data["stop_flag"] = False
        audio = sound_data["audio"]
        if audio is None:
            return
        while True:
            if sound_data["stop_flag"]:
                return
            audio_data = audio.raw_data
            sound_data["play_obj"] = sa.play_buffer(
                audio_data,
                num_channels=audio.channels,
                bytes_per_sample=audio.sample_width,
                sample_rate=audio.frame_rate,
            )
            while sound_data["play_obj"].is_playing():
                if sound_data["stop_flag"]:
                    sound_data["play_obj"].stop()
                    return
                time.sleep(0.1)
            if not sound_data["loop"]:
                return
            if sound_data["stop_flag"]:
                return

    def _play_sound(self, name: str) -> None:
        if self.current_sound and self.current_sound != name:
            self._stop_sound(self.current_sound)
        self.current_sound = name
        sound_data = self.sounds[name]
        self._stop_sound(name)
        sound_data["thread"] = threading.Thread(
            target=self._play_worker, args=(name,), daemon=True
        )
        sound_data["thread"].start()

    def _stop_sound(self, name: str) -> None:
        sound_data = self.sounds[name]
        sound_data["stop_flag"] = True
        play_obj = sound_data["play_obj"]
        if play_obj is not None:
            play_obj.stop()
            sound_data["play_obj"] = None
        thread = sound_data["thread"]
        if thread is not None and thread.is_alive():
            thread.join(timeout=0.1)
            sound_data["thread"] = None
        if self.current_sound == name:
            self.current_sound = None

    def _wait_until_finished(self, name: str) -> None:
        sound_data = self.sounds[name]
        thread = sound_data["thread"]
        if thread is not None:
            thread.join()

    def _countdown(self) -> None:
        for i in range(40, 0, -1):
            if not self.playing:
                return
            print(i)
            time.sleep(1)
        if self.playing:
            print("BOMB")
            self.playing = False
            self._play_sound("explosion")

    def start_ticking(self) -> None:
        if not self.playing:
            self.playing = True
            print("Bomb ticking!")
            self._play_sound("ticking")
            threading.Thread(target=self._countdown, daemon=True).start()

    def stop_ticking(self) -> None:
        if self.playing:
            self.playing = False
            print("DEFUSED")
            if self.current_sound:
                self._stop_sound(self.current_sound)
            time.sleep(0.1)
            self._play_sound("defused")
            self._wait_until_finished("defused")

    def stop_all(self) -> None:
        if self.current_sound:
            self._stop_sound(self.current_sound)
        self.playing = False

    def run(self, port: str = "COM4", baud: int = 9600) -> None:
        ser = serial.Serial(port, baud, timeout=1)
        print(f"Listening on {port} at {baud} baud...")
        try:
            while True:
                data = ser.read(1)
                if data:
                    char = data.decode("ascii").strip()
                    if char == "1":
                        self.start_ticking()
                    elif char == "0":
                        self.stop_ticking()
        except Exception as e:
            print(e)
        finally:
            self.stop_all()
            ser.close()


def main():
    bomb = BombController()
    bomb.run()


if __name__ == "__main__":
    main()
