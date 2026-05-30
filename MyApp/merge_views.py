import os

def append_and_cleanup():
    # Read contents
    with open("WelcomeView.swift", "r", encoding="utf-8") as f:
        welcome_content = f.read()
        
    with open("BiometricAuthView.swift", "r", encoding="utf-8") as f:
        biometric_content = f.read()
        
    # Append to ContentView.swift
    with open("ContentView.swift", "a", encoding="utf-8") as f:
        f.write("\n\n// MARK: - Appended Views for compilation\n\n")
        # Remove import SwiftUI to keep it clean
        welcome_clean = welcome_content.replace("import SwiftUI", "")
        biometric_clean = biometric_content.replace("import SwiftUI", "")
        f.write(welcome_clean)
        f.write("\n")
        f.write(biometric_clean)
        
    # Delete the standalone files since they are not in pbxproj
    os.remove("WelcomeView.swift")
    os.remove("BiometricAuthView.swift")

if __name__ == "__main__":
    append_and_cleanup()
    print("Successfully appended files to ContentView.swift and cleaned up.")
