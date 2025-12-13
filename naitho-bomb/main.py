import serial
import threading
import time
from pydub import AudioSegment
import simpleaudio as sa


# ------------------------------
#  Audio Player Class
# ------------------------------
class AudioPlayer:
    def __init__(self, file_path, loop=False):
        self.sound = AudioSegment.from_mp3(file_path)
        self.play_obj = None
        self.thread = None
        self.stop_flag = False
        self.loop = loop

    def _play_worker(self):
        """Worker thread for playing (looping or one-shot)."""
        self.stop_flag = False

        while True:
            audio_data = self.sound.raw_data
            self.play_obj = sa.play_buffer(
                audio_data,
                num_channels=self.sound.channels,
                bytes_per_sample=self.sound.sample_width,
                sample_rate=self.sound.frame_rate,
            )

            # Wait for sound to finish or stop signal
            while self.play_obj.is_playing():
                if self.stop_flag:
                    self.play_obj.stop()
                    return
                time.sleep(0.02)

            # One-shot mode ends after finishing
            if not self.loop:
                return

            # Loop continues unless stop_flag is set
            if self.stop_flag:
                return

    def start(self):
        self.stop()  # ensure nothing overlaps
        self.thread = threading.Thread(target=self._play_worker, daemon=True)
        self.thread.start()

    def stop(self):
        """Stop audio immediately and wait for thread to close."""
        self.stop_flag = True
        if self.play_obj:
            try:
                self.play_obj.stop()
            except:
                pass
        if self.thread and self.thread.is_alive():
            self.thread.join(timeout=0.1)

    def wait_until_finished(self):
        """Block until one-shot sound finishes."""
        if self.thread:
            self.thread.join()


# ------------------------------
#   Sound Manager
# ------------------------------
class SoundManager:
    def __init__(self, sounds):
        self.sounds = sounds
        self.current = None

    def play(self, name):
        # Stop previous sound
        if self.current and self.current != name:
            self.sounds[self.current].stop()

        self.current = name
        self.sounds[name].start()

    def stop(self, name=None):
        if name:
            self.sounds[name].stop()
        else:
            # Stop all sounds
            for snd in self.sounds.values():
                snd.stop()


# ------------------------------
#   Setup Sounds
# ------------------------------
sound_manager = SoundManager(
    {
        "ticking": AudioPlayer("resources/ticking2.mp3", loop=True),
        "defused": AudioPlayer("resources/defused.mp3", loop=False),
        "explosion": AudioPlayer("resources/explosion.mp3", loop=False),
    }
)


# ------------------------------
#   Bomb Logic
# ------------------------------
playing = False


def countdown():
    global playing

    for i in range(40, 0, -1):
        if not playing:
            return
        print(i)
        time.sleep(1)

    # Timer expired
    if playing:
        print("BOMB")
        playing = False
        sound_manager.play("explosion")


def start_ticking():
    global playing
    playing = True
    print("Bomb ticking!")

    sound_manager.play("ticking")
    threading.Thread(target=countdown, daemon=True).start()


def stop_ticking():
    global playing

    if playing:
        playing = False
        print("DEFUSED")

        # Stop all sounds completely
        sound_manager.stop()

        # Manually play defused without SoundManager interference
        snd = sound_manager.sounds["defused"]
        snd.start()  # start one-shot sound
        snd.wait_until_finished()  # block until done


# ------------------------------
#   Serial Loop
# ------------------------------
def main():
    ser = serial.Serial("COM4", 9600, timeout=1)
    print("Listening on COM4 at 9600 baud...")

    try:
        while True:
            data = ser.read(1)
            if data:
                char = data.decode("ascii").strip()
                if char == "1":
                    if not playing:
                        start_ticking()
                elif char == "0":
                    stop_ticking()

    except Exception as e:
        print(e)

    finally:
        sound_manager.stop()
        ser.close()


if __name__ == "__main__":
    main()
