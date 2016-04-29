//
//  NewUnarchiverUITests.swift
//  NewUnarchiverUITests
//
//  Created by Serhii Merenkov on 4/5/16.
//  Copyright © 2016 SoftGames. All rights reserved.
//

import XCTest

class NewUnarchiverUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
       
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
  
//    func testEnather() {
//        
//        let app = XCUIApplication()
//        app.buttons["Archive"].tap()
//        
//        let collectionViewsQuery = app.sheets.collectionViews
//        collectionViewsQuery.buttons["ZIP+Password"].tap()
//        app.buttons["alertBg"].tap()
//        
//        let tablesQuery = app.tables
//        tablesQuery.staticTexts["FewWordsAbout.txt"].tap()
//        
//        let deleteButton = app.buttons["Delete"]
//        deleteButton.tap()
//        let deleteButton2 = collectionViewsQuery.buttons["Delete"]
//        deleteButton2.tap()
//        
//        tablesQuery.staticTexts["FewWordsAbout.zip"].tap()
//        deleteButton.tap()
//        deleteButton2.tap()
//        
//    }
    
/*    func testABCFiles() {
        
        let app = XCUIApplication()
        let tablesQuery = app.tables.element;
        tablesQuery.cells.elementBoundByIndex(0).tap()
        
     //   app.buttons.elementBoundByIndex(5).tap() //app.buttons["Add"].tap()
        
        let sheetsQuery = app.sheets
        let collectionViewsQuery = sheetsQuery.collectionViews
        snapshot("0_NO_files")
        /*
        collectionViewsQuery.buttons.elementBoundByIndex(1).tap() //buttons["File"].tap()
        app.buttons["txtIcon"].tap()
        */
        app.scrollViews.otherElements.buttons["txtIcon"].tap()
        tablesQuery.cells.elementBoundByIndex(0).tap()
     
        app.buttons.elementBoundByIndex(8).tap() //app.buttons["Copy"].tap()
        collectionViewsQuery.buttons.elementBoundByIndex(2).tap()// .buttons["Rename"].tap()
        
        let textField = app.images["alertContentFolder"].childrenMatchingType(.TextField).element
        
        textField.tap();
        let deleteKey = app.keyboards.keys["delete"]
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
//        deleteKey.tap()
//        deleteKey.tap()
        
        textField.typeText("Few")
        textField.typeText("Words")
        textField.typeText("About1")
        deleteKey.tap()
        app.images["alertContentFolder"].buttons.elementBoundByIndex(0).tap()
        
        tablesQuery.cells.elementBoundByIndex(0).tap()
        
        let archiveButton = app.buttons.elementBoundByIndex(9)
        archiveButton.tap()
        
        let collectionViewsQuery2 = sheetsQuery.collectionViews
        collectionViewsQuery2.buttons.elementBoundByIndex(0).tap()
        
    }
   */
    
    /*
    func testiPhone() {
       
        let app = XCUIApplication()
    
        let tablesQuery = app.tables.element;
        tablesQuery.cells.elementBoundByIndex(0).tap()
        
        //   app.buttons.elementBoundByIndex(5).tap() //app.buttons["Add"].tap()
        
        let sheetsQuery = app.sheets
        let collectionViewsQuery = sheetsQuery.collectionViews
        snapshot("1_NO_files")
        /*
        collectionViewsQuery.buttons.elementBoundByIndex(1).tap() //buttons["File"].tap()
        app.buttons["txtIcon"].tap()
        */
        app.scrollViews.otherElements.buttons.elementBoundByIndex(0).tap() //["txtIcon"].tap()
        tablesQuery.cells.elementBoundByIndex(0).tap()
        
        app.buttons.elementBoundByIndex(8).tap() //app.buttons["Copy"].tap()
        collectionViewsQuery.buttons.elementBoundByIndex(2).tap()// .buttons["Rename"].tap()
        
        let textField = app.images["alertContentFolder"].childrenMatchingType(.TextField).element
        
        textField.tap();
        let deleteKey = app.keyboards.keys["delete"]
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
        //        deleteKey.tap()
        //        deleteKey.tap()
        
        textField.typeText("Few")
        textField.typeText("Words")
        textField.typeText("About1")
        deleteKey.tap()
        app.images["alertContentFolder"].buttons.elementBoundByIndex(0).tap()
        
        tablesQuery.cells.elementBoundByIndex(0).tap()
        
        let archiveButton = app.buttons.elementBoundByIndex(9)
        archiveButton.tap()
        
        let collectionViewsQuery2 = sheetsQuery.collectionViews
        collectionViewsQuery2.buttons.elementBoundByIndex(0).tap()

        
        let tablesQuery2 = app.tables.element;
        
//        tablesQuery2.cells.elementBoundByIndex(2).tap() //staticTexts["Inbox"].tap()
//        
//        snapshot("8_Inbox")
        
        app.images["folderNavBarIcon"].tap()
        snapshot("2_Menu")
        app.scrollViews.otherElements.buttons.elementBoundByIndex(0).tap() //["Home"].tap()
        snapshot("0_Home")
        tablesQuery2.cells.elementBoundByIndex(0).tap() //staticTexts["My Files"].tap()
        
        //snapshot("9_SelectFile")
        
        let tablesQuery2Second = app.tables.element;
        tablesQuery2Second.cells.elementBoundByIndex(0).tap()  //staticTexts["Example from mail.zip"].tap()
//        snapshot("3_SelectFile")
        
      
        let formatString : String = String(format: "accessibilityLabel == '%@'", "Archive")
        NSLog("text for search = %@", formatString)
        
       // let predicateArchive :NSPredicate = NSPredicate(format: formatString)
         //ToolBarBtnArchive = 3
        app.buttons.elementBoundByIndex(7).tap() //elementMatchingPredicate(predicateArchive).tap()
            
     //       elementAtIndex(<#T##index: UInt##UInt#>) .elementBoundByIndex(3).tap()
        snapshot("4_Archive")
        let sheetsQuery11 = app.sheets
        
        let collectionViewsQuery33 = sheetsQuery11.collectionViews
        collectionViewsQuery33.buttons.elementBoundByIndex(1).tap() //["ZIP+Password"].tap()
        
        let textFieldPassword = app.images["alertContentFolder"].childrenMatchingType(.TextField).element
        textFieldPassword.tap()
        textFieldPassword.typeText("Qwe")
        
        snapshot("5_ArchivePass")
        
        
        //Deleting All created files ))
        app.images["alertContentFolder"].buttons.elementBoundByIndex(0).tap()
        //app.buttons["alertBg"].tap()
        
        let tablesQueryForDelete = app.tables.cells
        tablesQueryForDelete.elementBoundByIndex(0).tap()  //staticTexts["FewWordsAbout.txt"].tap()
        
        var deleteButton = app.buttons.elementBoundByIndex(9) //app.buttons["Delete"]
        deleteButton.tap()
        app.sheets.collectionViews.buttons.elementBoundByIndex(0).tap()
        
        tablesQueryForDelete.elementBoundByIndex(0).tap()  //staticTexts["FewWordsAbout.txt"].tap()
        deleteButton = app.buttons.elementBoundByIndex(8)
        deleteButton.tap()
        app.sheets.collectionViews.buttons.elementBoundByIndex(0).tap()
        
        tablesQueryForDelete.elementBoundByIndex(0).tap()  //staticTexts["FewWordsAbout.txt"].tap()
        deleteButton = app.buttons.elementBoundByIndex(7)
        deleteButton.tap()
        app.sheets.collectionViews.buttons.elementBoundByIndex(0).tap()
        
    }
    
*/
    func testAnother() {
        
        
    }
  
    func testiPad() {
        
        XCUIDevice.sharedDevice().orientation = .LandscapeLeft
        
        let app = XCUIApplication()
        
        let tablesQuery = app.tables.element;
        tablesQuery.cells.elementBoundByIndex(0).tap()
        
        //   app.buttons.elementBoundByIndex(5).tap() //app.buttons["Add"].tap()
        
        let sheetsQuery = app.sheets
        let collectionViewsQuery = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(2)
        XCUIDevice.sharedDevice().orientation = .Portrait
        XCUIDevice.sharedDevice().orientation = .LandscapeLeft
        
        snapshot("1_NO_files")
        /*
         collectionViewsQuery.buttons.elementBoundByIndex(1).tap() //buttons["File"].tap()
         app.buttons["txtIcon"].tap()
         */
        app.scrollViews.otherElements.buttons.elementBoundByIndex(0).tap() //["txtIcon"].tap()
        tablesQuery.cells.elementBoundByIndex(0).tap()
        
        app.buttons.elementBoundByIndex(8).tap() //app.buttons["Copy"].tap()
        collectionViewsQuery.buttons.elementBoundByIndex(2).tap()// .buttons["Rename"].tap()
        
        let textField = app.images["alertContentFolder"].childrenMatchingType(.TextField).element
        
        textField.tap();
        let deleteKey = app.keyboards.keys["delete"]
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
        //        deleteKey.tap()
        //        deleteKey.tap()
        
        textField.typeText("Few")
        textField.typeText("Words")
        textField.typeText("About1")
        deleteKey.tap()
        app.images["alertContentFolder"].buttons.elementBoundByIndex(0).tap()
        
        tablesQuery.cells.elementBoundByIndex(0).tap()
        
        let archiveButton = app.buttons.elementBoundByIndex(9)
        archiveButton.tap()
        
        var collectionViewsQuery2 = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(2)
        collectionViewsQuery2.buttons.elementBoundByIndex(0).tap()
        
        
        let tablesQuery2 = app.tables.element;
        
        //        tablesQuery2.cells.elementBoundByIndex(2).tap() //staticTexts["Inbox"].tap()
        //
        //        snapshot("8_Inbox")
        
        app.images["folderNavBarIcon"].tap()
        
        let homeButton = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(2).childrenMatchingType(.Other).elementBoundByIndex(2).childrenMatchingType(.Other).elementBoundByIndex(1).buttons.elementBoundByIndex(0)
        
        snapshot("2_Menu")
        //app.scrollViews.otherElements.buttons.elementBoundByIndex(0).tap() //["Home"].tap()
        homeButton.tap()
        XCUIDevice.sharedDevice().orientation = .Portrait
        XCUIDevice.sharedDevice().orientation = .LandscapeLeft
        
        snapshot("0_Home")
        tablesQuery2.cells.elementBoundByIndex(0).tap() //staticTexts["My Files"].tap()
        
        //snapshot("9_SelectFile")
        XCUIDevice.sharedDevice().orientation = .Portrait
        XCUIDevice.sharedDevice().orientation = .LandscapeLeft
        
        let tablesQuery2Second = app.tables.element;
        tablesQuery2Second.cells.elementBoundByIndex(0).tap()  //staticTexts["Example from mail.zip"].tap()
        //        snapshot("3_SelectFile")
       
        let formatString : String = String(format: "accessibilityLabel == '%@'", "Archive")
        NSLog("text for search = %@", formatString)
        
        // let predicateArchive :NSPredicate = NSPredicate(format: formatString)
        //ToolBarBtnArchive = 3
        app.buttons.elementBoundByIndex(7).tap() //elementMatchingPredicate(predicateArchive).tap()
        
        //       elementAtIndex(<#T##index: UInt##UInt#>) .elementBoundByIndex(3).tap()
        snapshot("4_Archive")
        let sheetsQuery11 = app.sheets
        
//        let collectionViewsQuery33 = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(2)
//            .buttons.elementBoundByIndex(1).tap() //["ZIP+Password"].tap()
        /*
        collectionViewsQuery2 = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(2)
        collectionViewsQuery2.buttons.elementBoundByIndex(1).tap()
        
        let textFieldPassword = app.images["alertContentFolder"].childrenMatchingType(.TextField).element
        textFieldPassword.tap()
        textFieldPassword.typeText("Qwe")
        
        snapshot("5_ArchivePass")
        
        
        //Deleting All created files ))
        app.images["alertContentFolder"].buttons.elementBoundByIndex(0).tap()
        //app.buttons["alertBg"].tap()
        
        let tablesQueryForDelete = app.tables.cells
        tablesQueryForDelete.elementBoundByIndex(0).tap()  //staticTexts["FewWordsAbout.txt"].tap()
        
        let confirmDelete = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(2)
        
        
        var deleteButton = app.buttons.elementBoundByIndex(9) //app.buttons["Delete"]
        deleteButton.tap()
        confirmDelete.buttons.elementBoundByIndex(0).tap()
        
        tablesQueryForDelete.elementBoundByIndex(0).tap()  //staticTexts["FewWordsAbout.txt"].tap()
        deleteButton = app.buttons.elementBoundByIndex(8)
        deleteButton.tap()
        confirmDelete.buttons.elementBoundByIndex(0).tap()
        
        tablesQueryForDelete.elementBoundByIndex(0).tap()  //staticTexts["FewWordsAbout.txt"].tap()
        deleteButton = app.buttons.elementBoundByIndex(7)
        deleteButton.tap()
        confirmDelete.buttons.elementBoundByIndex(0).tap()
        */
    }

}
