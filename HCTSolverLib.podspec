#
#  Be sure to run `pod spec lint HCTSolverLib.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "HCTSolverLib"
  spec.version      = "1.0"
  spec.swift_versions = [ "5.0" ]
  spec.summary      = "This library contains algorithm to generate HCT(Hue, Chroma, Tone) colors."
  spec.description  = <<-DESC
  The origin for these logic came from this repository: https://github.com/material-foundation/material-color-utilities. This library contains algorithm to generate HCT(Hue, Chroma, Tone) colors. We can use this library to generate colors of different tone for a given color.
                   DESC

  spec.homepage     = "https://github.com/MArman88/HCTSolver"

  spec.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
      Licensed under the Apache License, Version 2.0 (the "License");
      you may not use this file except in compliance with the License.
      You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

      Unless required by applicable law or agreed to in writing, software
      distributed under the License is distributed on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
      See the License for the specific language governing permissions and
      limitations under the License.
      LICENSE
    }


  spec.author             = { "arman" => "mehbubearman@gmail.com" }

  spec.platform     = :ios, "12.0"

  spec.source       = { :git => "https://github.com/MArman88/HCTSolver.git", :tag => "#{spec.version}" }

  spec.source_files  = "Classes", "HCTSolverLib/**/*.{swift}"
end
