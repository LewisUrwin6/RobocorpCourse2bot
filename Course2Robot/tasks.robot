*** Settings ***
Documentation     Template robot main suite.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF
Library           RPA.Archive
Library           RPA.Robocorp.Vault

*** Tasks ***
Order Robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Wait Until Keyword Succeeds    1 min    2 sec    Submit the form
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts

Minimal task
    Log    Done.

*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    orders.csv
    ${orders}=    Read table from CSV    orders.csv
    Log    Found columns: ${orders.columns}
    [Return]    ${orders}

Close the annoying modal
    ${secret}=    Get Secret    robotsparebin
    Click Button    ${secret}[code]

Fill the form
    [Arguments]    ${row}
    IF    ${row}[Head] == ${1}
        Click Element    //*[@id="head"]/option[2]
    END
    IF    ${row}[Head] == ${2}
        Click Element    //*[@id="head"]/option[3]
    END
    IF    ${row}[Head] == ${3}
        Click Element    //*[@id="head"]/option[4]
    END
    IF    ${row}[Head] == ${4}
        Click Element    //*[@id="head"]/option[5]
    END
    IF    ${row}[Head] == ${5}
        Click Element    //*[@id="head"]/option[6]
    END
    IF    ${row}[Head] == ${6}
        Click Element    //*[@id="head"]/option[7]
    END
    Click Button    ${row}[Body]
    Input Text    class=form-control    ${row}[Legs]
    Input Text    address    ${row}[Address]

Preview the robot
    Click Button    preview

Submit the form
    FOR    ${i}    IN RANGE    999999
        Click Button    order
        ${Visible}=    Is Element Visible    id:receipt
        Exit For Loop If    ${Visible}
    END

Store the receipt as a PDF file
    [Arguments]    ${OrderNumber}
    Wait Until Element Is Visible    id:receipt
    ${Receipt_HTML}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${Receipt_HTML}    ${OUTPUT_DIR}${/}${OrderNumber}.pdf
    [Return]    ${OUTPUT_DIR}${/}${OrderNumber}.pdf

Take a screenshot of the robot
    [Arguments]    ${OrderNumber}
    Screenshot    //*[@id="robot-preview-image"]    ${OUTPUT_DIR}${/}${OrderNumber}.png
    [Return]    ${OUTPUT_DIR}${/}${OrderNumber}.png

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf    ${pdf}
    Add Watermark Image To Pdf    ${screenshot}    ${pdf}
    Close All Pdfs

Go to order another robot
    Click Button    order-another

Create a ZIP file of the receipts
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/PDFs.zip
    Archive Folder With Zip
    ...    ${OUTPUT_DIR}
    ...    ${zip_file_name}
