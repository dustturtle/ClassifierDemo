// first: the simplest UI version. Need user interactive, with MLImageClassifierBuilder.

// https://github.com/appcoda/CreateMLQuickDemo/raw/master/resources/FruitImages.zip  test image Download url

// first: the simplest UI version. Need user interactive, with MLImageClassifierBuilder.

//import CreateMLUI
//let builder = MLImageClassifierBuilder()
//builder.showInLiveView()


// second: auto with codes version. with MLImageClassifier and logic codes.
import CreateML
import Foundation

//let trainDir = URL(fileURLWithPath: "/Users/zhenweiguan/Desktop/MLPlayground/FruitImages/TrainingData")
//let testDir = URL(fileURLWithPath: "/Users/zhenweiguan/Desktop/MLPlayground/FruitImages/TestingData")
//
//let model = try MLImageClassifier(trainingData: .labeledDirectories(at: trainDir))
//
//let eval = model.evaluation(on: .labeledDirectories(at: testDir))
//
//try model.write(to: URL(fileURLWithPath: "/Users/zhenweiguan/Desktop/MLPlayground/FruitImages/FruitClassifier"))



// here we can also use .labeledDirectories directly (with local folders url)
//let data = try MLDataTable(contentsOf: URL(fileURLWithPath: "/Users/zhenweiguan/Desktop/MLPlayground/spam.json"))
//let (trainingData, testingData) = data.randomSplit(by: 0.8, seed: 5)
//let spamClassifier = try MLTextClassifier(trainingData: trainingData, textColumn: "text", labelColumn: "label")
//
//let trainingAccuracy = (1.0 - spamClassifier.trainingMetrics.classificationError) * 100
//let validationAccuracy = (1.0 - spamClassifier.validationMetrics.classificationError) * 100
//
//let evaluationMetrics = spamClassifier.evaluation(on: testingData)
//let evaluationAccuracy = (1.0 - evaluationMetrics.classificationError) * 100
//
//let metadata = MLModelMetadata(author: "dustturtle", shortDescription: "A model trained to classify spam messages", version: "1.0")
//try spamClassifier.write(to: URL(fileURLWithPath: "/Users/zhenweiguan/Desktop/MLPlayground/Save/SpamDetector.mlmodel"), metadata: metadata)



let houseData = try MLDataTable(contentsOf: URL(fileURLWithPath: "/Users/zhenweiguan/Desktop/MLPlayground/HouseData.csv"))
let (trainingCSVData, testCSVData) = houseData.randomSplit(by: 0.8)

let pricer = try MLRegressor(trainingData: houseData, targetColumn: "MEDV")

let csvMetadata = MLModelMetadata(author: "dustturtle", shortDescription: "A model used to determine the price of a house based on some features.", version: "1.0")
try pricer.write(to: URL(fileURLWithPath: "/Users/zhenweiguan/Desktop/MLPlayground/Save/HousePricer.mlmodel"), metadata: csvMetadata)

// 训练结果表明，这个误差相当大。 我认为这3个参数根本搞不定这个价格预测模型啦，需要更多的feature才可以。

