# Blender 3.1.0 (hash c77597cd0e15 built 2022-03-09 00:44:13)
# (GUI流程) https://youtu.be/dGU7ot25P9M
import bpy
import os
import sys
import tempfile
import time
import zipfile

# 開始計時
print("FY-開始: %s %s" % (sys.argv[-2],sys.argv[-1]))

# 時間戳
def timeStamp():
    t=time.time()
    return "%s (%s)" % (time.asctime(time.localtime(t)),t)

# 找出解壓縮後 USDC 位置
def findUSDC(dirpath):
    files = os.listdir(dirpath)
    dirs = []
    for file in files:
        parts = file.split('.')
        filepath = os.path.join(dirpath, file)
        if os.path.isdir(filepath):
            dirs.append(filepath)
        elif len(parts) > 0 and parts[-1] == 'usdc':
            return filepath
    for dir in dirs:
        file = findUSDC(dir)
        if file != '':
            return file
    return ''

# 將 USDZ 解壓縮
def extractUSDC(filepath):
    try:
        if os.path.exists(filepath)==False:
            raise Exception(filepath + " 不存在")
        filePath, fileName = os.path.split(filepath)
        fileName, fileType = fileName.split('.')
    except Exception as e:
        print(e, "輸入不正確")
        return None
    if fileType == 'usdz':
        with zipfile.ZipFile(filepath, 'r') as zf:
            # Create a temp directory to extract to
            tempPath = tempfile.mkdtemp()
            try:
                zf.extractall(tempPath)
            except Exception as e:
                print(e)
            zf.close()
            # Find the usdc file
            usdcFile = findUSDC(tempPath)
            # 遞迴處理
            return extractUSDC(usdcFile)
    elif fileType == 'usdc':
        print(filepath)
        return filepath
    else:
        print("輸入不正確")
        return None
        
# 清除, 匯入USD, 匯出GLB
def main(usdzFileName = sys.argv[-1], usdzFileDir = os.getcwd()):
    # (清除) https://blender.stackexchange.com/questions/46990/how-to-completely-remove-all-loaded-data-from-blender#answer-46991
    bpy.ops.wm.read_factory_settings(use_empty=True)
    # (匯入USD) https://docs.blender.org/api/current/bpy.ops.wm.html?highlight=usd#bpy.ops.wm.usd_import
    iFile = os.path.join(usdzFileDir, usdzFileName)
    print("\t\tFY-輸入: ",iFile,os.path.getsize(iFile),"Bytes")
    iFile = extractUSDC(iFile)
    if iFile==None:
        print("\t\tFY-輸出: ",None)
        return None
    bpy.ops.wm.usd_import(filepath=iFile,import_usd_preview=True)
    # (匯出GLB) https://docs.blender.org/api/current/bpy.ops.export_scene.html?highlight=glb#bpy.ops.export_scene.gltf
    fileName, fileType = usdzFileName.split('.')
    oFile = "%s.glb" % os.path.join(usdzFileDir, fileName)
    bpy.ops.export_scene.gltf(filepath=oFile, export_image_format="JPEG")
    print("\t\tFY-輸出: ",oFile,os.path.getsize(oFile),"Bytes")
    return oFile

# 主程序
nowDir = os.getcwd()
for file in os.listdir(nowDir):
    parts = file.split('.')
    if len(parts) > 0 and parts[-1] == 'usdz':
        print("\tFY-開始(%s): %s" % (file,timeStamp()))
        main(file, nowDir)
        print("\tFY-結束(%s): %s" % (file,timeStamp()))

# 結束計時
print("FY-結束: " + timeStamp())
