import generator as g
import scipy.io.wavfile as wavfile
import numpy as np
import matplotlib.pyplot as plt


fs = 220500
f = 1000

print("Calling wave")
a = g.wave(fs,f)

#plot waveform
time = np.linspace(0, len(a)/fs, len(a))
plt.figure(1)
plt.plot(time,a)
plt.xlabel("Time (s)")
plt.ylabel("Amplitude")
plt.title("Waveform Generated")

#create new wav file
x = np.array(a, dtype = 'int16')
name = str(f)+"Hz.wav"
wavfile.write(name,fs,a)
