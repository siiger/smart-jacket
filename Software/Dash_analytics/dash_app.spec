# -*- mode: python ; coding: utf-8 -*-

#manually add Start to avoid rerusion limit error==>
import sys
sys.setrecursionlimit(5000)
#manually add End<==

block_cipher = None
added_files = [
         ('/Library/Frameworks/Python.framework/Versions/3.9/lib/python3.9/site-packages/dash', './dash'), 
         ('sensordata.csv', '.'),
         ('sensordataactivity.csv', '.'),
         ]

a = Analysis(['app.py'],
             pathex=['/Users/d/Projects/python/test/test_executable_file'],
             binaries=[],
             datas=added_files,
             hiddenimports=['pkg_resources.py2_warn'],
             hookspath=[],
             hooksconfig={},
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)
pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)

exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,  
          [],
          name='app',
          debug=False,
          bootloader_ignore_signals=False,
          strip=False,
          upx=True,
          upx_exclude=[],
          runtime_tmpdir=None,
          console=False,
          disable_windowed_traceback=False,
          target_arch=None,
          codesign_identity=None,
          entitlements_file=None )
app = BUNDLE(exe,
             name='app.app',
             icon=None,
             bundle_identifier=None)
