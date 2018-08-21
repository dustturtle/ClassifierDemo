// first: the simplest UI version. Need user interactive, with MLImageClassifierBuilder.

// https://github.com/appcoda/CreateMLQuickDemo/raw/master/resources/FruitImages.zip  test image Download url

//import CreateMLUI
//let builder = MLImageClassifierBuilder()
//builder.showInLiveView()


// second: auto with codes version. with MLImageClassifier and logic codes.
import CreateML
import Foundation

let trainDir = URL(fileURLWithPath: "/Users/zhenweiguan/Desktop/MLPlayground/FruitImages/TrainingData")
let testDir = URL(fileURLWithPath: "/Users/zhenweiguan/Desktop/MLPlayground/FruitImages/TestingData")

let model = try MLImageClassifier(trainingData: .labeledDirectories(at: trainDir))

let eval = model.evaluation(on: .labeledDirectories(at: testDir))

try model.write(to: URL(fileURLWithPath: "/Users/zhenweiguan/Desktop/MLPlayground/FruitImages/FruitClassifier"))
