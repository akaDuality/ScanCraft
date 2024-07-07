import Foundation

extension String {
    func run() {
        print(self)
        let pipe = Pipe()
        let process = Process()
        process.launchPath = "/bin/sh"
        process.arguments = ["-c", self]
        process.standardOutput = pipe
        
        let fileHandle = pipe.fileHandleForReading
        process.launch()
        
        let output = String(data: fileHandle.readDataToEndOfFile(), encoding: .utf8)
        if let output {
            for line in output.split(separator: "\n") {
                print(line)
            }
        } else {
            print("No output")
        }
    }
}

class BlenderToGlbConverter {
    func convertToGlb(url: URL) {
        // TODO: Prepare user to give permission
        let path = url.path(percentEncoded: false)
"""
cd \"\(path)\"\n
/Applications/Blender.app/Contents/MacOS/Blender -b -P /Users/mikhail/Developer/Photogrammetry/usdz_to_glb.py
""".run()
        
    } // TODO: Change path to script
}
