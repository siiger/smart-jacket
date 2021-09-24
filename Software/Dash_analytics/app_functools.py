import numpy as np
from scipy.signal import find_peaks


#Calulation functions
def data_peaks(signal, times):
  array = np.array(signal, dtype=float)
  peaks, _ = find_peaks(array, height=0)
  len = peaks.size
  tout, sigout = [], []
  j = 0
  for j in range(len - 1):
      tout.append(times[peaks[j]])
      sigout.append(signal[peaks[j]])
  return [tout, sigout]



def calculate_freq(signal, times):
  array = np.array(signal, dtype=float)
  peaks, _ = find_peaks(array, height=0)
  len = peaks.size
  fout, tout = [], []
  j, i = 0, 0
  dT = 60000
  for j in range(len - 1):
    while ((times[peaks[i]] - times[peaks[j]]).total_seconds() * 1000 <= dT) and i < len - 1:
      i += 1
    else:
      fout.append(i - j)
      tout.append(times[peaks[j]])
      i = j    
  return [tout, fout]



def calculate_irreg(signal, times):
  array = np.array(signal, dtype=float)
  peaks, _ = find_peaks(array, height=0)
  len = peaks.size
  irrout, tout, = [], []
  j = 2
  for j in range(len - 3):
    irr = 100*abs((times[peaks[j+1]] - times[peaks[j]]).total_seconds() - (times[peaks[j+2]] - times[peaks[j+1]]).total_seconds())/( (times[peaks[j+1]] - times[peaks[j]]).total_seconds()+ (times[peaks[j+2]] - times[peaks[j+1]]).total_seconds())
    irrout.append(irr)
    tout.append(times[peaks[j]])
  return [tout, irrout]



def calculate_divide(signalA, signalB):
  len = signalA.size
  meanA, meanB = np.mean(signalA), np.mean(signalB)
  divout = []
  for j in range(len):
    di = (1000+meanA - signalA[j])/(1000+meanB - signalB[j])
    divout.append(di)
  return  divout
#