-- Declare the Tax Authority Code that will be used all throughout Indiana Default Data
PRINT ('Deploying Indiana Tax Forms')
DECLARE @TaxAuthorityCode NVARCHAR(10) = 'IN'
	, @TaxAuthorityId INT
SELECT @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = @TaxAuthorityCode


-- Origin/Destination State
/* Generate script for Origin/Destination States.
select 'UNION ALL SELECT intOriginDestinationStateId = ' + CAST(intOriginDestinationStateId AS NVARCHAR(10))
	+ CASE WHEN strOriginDestinationState IS NULL THEN ', strOriginDestinationState = NULL' ELSE ', strOriginDestinationState = ''' + strOriginDestinationState + ''''  END
from tblTFOriginDestinationState
*/
DECLARE @OriginDestinationStates AS TFOriginDestinationStates

INSERT INTO @OriginDestinationStates (
	intOriginDestinationStateId
    , strOriginDestinationState
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intOriginDestinationStateId = 1, strOriginDestinationState = 'AL'
UNION ALL SELECT intOriginDestinationStateId = 2, strOriginDestinationState = 'AK'
UNION ALL SELECT intOriginDestinationStateId = 3, strOriginDestinationState = 'AZ'
UNION ALL SELECT intOriginDestinationStateId = 4, strOriginDestinationState = 'AR'
UNION ALL SELECT intOriginDestinationStateId = 5, strOriginDestinationState = 'CA'
UNION ALL SELECT intOriginDestinationStateId = 6, strOriginDestinationState = 'CO'
UNION ALL SELECT intOriginDestinationStateId = 7, strOriginDestinationState = 'CT'
UNION ALL SELECT intOriginDestinationStateId = 8, strOriginDestinationState = 'DE'
UNION ALL SELECT intOriginDestinationStateId = 9, strOriginDestinationState = 'FL'
UNION ALL SELECT intOriginDestinationStateId = 10, strOriginDestinationState = 'GA'
UNION ALL SELECT intOriginDestinationStateId = 11, strOriginDestinationState = 'HI'
UNION ALL SELECT intOriginDestinationStateId = 12, strOriginDestinationState = 'ID'
UNION ALL SELECT intOriginDestinationStateId = 13, strOriginDestinationState = 'IL'
UNION ALL SELECT intOriginDestinationStateId = 14, strOriginDestinationState = 'IN'
UNION ALL SELECT intOriginDestinationStateId = 15, strOriginDestinationState = 'IA'
UNION ALL SELECT intOriginDestinationStateId = 16, strOriginDestinationState = 'KS'
UNION ALL SELECT intOriginDestinationStateId = 17, strOriginDestinationState = 'KY'
UNION ALL SELECT intOriginDestinationStateId = 18, strOriginDestinationState = 'LA'
UNION ALL SELECT intOriginDestinationStateId = 19, strOriginDestinationState = 'ME'
UNION ALL SELECT intOriginDestinationStateId = 20, strOriginDestinationState = 'MD'
UNION ALL SELECT intOriginDestinationStateId = 21, strOriginDestinationState = 'MA'
UNION ALL SELECT intOriginDestinationStateId = 22, strOriginDestinationState = 'MI'
UNION ALL SELECT intOriginDestinationStateId = 23, strOriginDestinationState = 'MN'
UNION ALL SELECT intOriginDestinationStateId = 24, strOriginDestinationState = 'MS'
UNION ALL SELECT intOriginDestinationStateId = 25, strOriginDestinationState = 'MO'
UNION ALL SELECT intOriginDestinationStateId = 26, strOriginDestinationState = 'MT'
UNION ALL SELECT intOriginDestinationStateId = 27, strOriginDestinationState = 'NE'
UNION ALL SELECT intOriginDestinationStateId = 28, strOriginDestinationState = 'NV'
UNION ALL SELECT intOriginDestinationStateId = 29, strOriginDestinationState = 'NH'
UNION ALL SELECT intOriginDestinationStateId = 30, strOriginDestinationState = 'NJ'
UNION ALL SELECT intOriginDestinationStateId = 31, strOriginDestinationState = 'NM'
UNION ALL SELECT intOriginDestinationStateId = 32, strOriginDestinationState = 'NY'
UNION ALL SELECT intOriginDestinationStateId = 33, strOriginDestinationState = 'NC'
UNION ALL SELECT intOriginDestinationStateId = 34, strOriginDestinationState = 'ND'
UNION ALL SELECT intOriginDestinationStateId = 35, strOriginDestinationState = 'OH'
UNION ALL SELECT intOriginDestinationStateId = 36, strOriginDestinationState = 'OK'
UNION ALL SELECT intOriginDestinationStateId = 37, strOriginDestinationState = 'OR'
UNION ALL SELECT intOriginDestinationStateId = 38, strOriginDestinationState = 'PA'
UNION ALL SELECT intOriginDestinationStateId = 39, strOriginDestinationState = 'RI'
UNION ALL SELECT intOriginDestinationStateId = 40, strOriginDestinationState = 'SC'
UNION ALL SELECT intOriginDestinationStateId = 41, strOriginDestinationState = 'SD'
UNION ALL SELECT intOriginDestinationStateId = 42, strOriginDestinationState = 'TN'
UNION ALL SELECT intOriginDestinationStateId = 43, strOriginDestinationState = 'TX'
UNION ALL SELECT intOriginDestinationStateId = 44, strOriginDestinationState = 'UT'
UNION ALL SELECT intOriginDestinationStateId = 45, strOriginDestinationState = 'VT'
UNION ALL SELECT intOriginDestinationStateId = 46, strOriginDestinationState = 'VA'
UNION ALL SELECT intOriginDestinationStateId = 47, strOriginDestinationState = 'WA'
UNION ALL SELECT intOriginDestinationStateId = 48, strOriginDestinationState = 'WV'
UNION ALL SELECT intOriginDestinationStateId = 49, strOriginDestinationState = 'WI'
UNION ALL SELECT intOriginDestinationStateId = 50, strOriginDestinationState = 'WY'

EXEC uspTFUpgradeOriginDestinationState @OriginDestinationStates = @OriginDestinationStates


-- Product Codes
/* Generate script for Product Codes. Specify Tax Authority Id to filter out specific Product Codes only.
select 'UNION ALL SELECT intProductCodeId = ' + CAST(intProductCodeId AS NVARCHAR(10)) 
	+ CASE WHEN strProductCode IS NULL THEN ', strProductCode = NULL' ELSE ', strProductCode = ''' + strProductCode + ''''  END
	+ CASE WHEN strDescription IS NULL THEN ', strDescription = NULL' ELSE ', strDescription = ''' + strDescription + ''''  END
	+ CASE WHEN strProductCodeGroup IS NULL THEN ', strProductCodeGroup = NULL' ELSE ', strProductCodeGroup = ''' + strProductCodeGroup + ''''  END
	+ CASE WHEN strNote IS NULL THEN ', strNote = NULL' ELSE ', strNote = ''' + strNote + '''' END 
from tblTFProductCode
where intTaxAuthorityId = @TaxAuthorityId
*/
DECLARE @ProductCodes AS TFProductCodes

INSERT INTO @ProductCodes (
	intProductCodeId
    , strProductCode
    , strDescription
    , strProductCodeGroup
    , strNote
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intProductCodeId = 263, strProductCode = 'M00', strDescription = 'Methanol (100%)', strProductCodeGroup = 'Gasohol Ethanol Blend', strNote = NULL
UNION ALL SELECT intProductCodeId = 264, strProductCode = 'M11', strDescription = 'Methanol (11%)', strProductCodeGroup = 'Gasohol Ethanol Blend', strNote = NULL
UNION ALL SELECT intProductCodeId = 265, strProductCode = '125', strDescription = 'Aviation Gasoline', strProductCodeGroup = 'Gasohol Ethanol Blend', strNote = NULL
UNION ALL SELECT intProductCodeId = 266, strProductCode = '090', strDescription = 'Additive Miscellaneous', strProductCodeGroup = 'Blending Components', strNote = NULL
UNION ALL SELECT intProductCodeId = 267, strProductCode = '248', strDescription = 'Benzene', strProductCodeGroup = 'Blending Components', strNote = NULL
UNION ALL SELECT intProductCodeId = 268, strProductCode = '198', strDescription = 'Butylene', strProductCodeGroup = 'Blending Components', strNote = NULL
UNION ALL SELECT intProductCodeId = 269, strProductCode = '249', strDescription = 'ETBE', strProductCodeGroup = 'Blending Components', strNote = NULL
UNION ALL SELECT intProductCodeId = 270, strProductCode = '052', strDescription = 'Ethane', strProductCodeGroup = 'Blending Components', strNote = NULL
UNION ALL SELECT intProductCodeId = 271, strProductCode = '196', strDescription = 'Ethylene', strProductCodeGroup = 'Blending Components', strNote = NULL
UNION ALL SELECT intProductCodeId = 272, strProductCode = '058', strDescription = 'Isobutane', strProductCodeGroup = 'Blending Components', strNote = NULL
UNION ALL SELECT intProductCodeId = 273, strProductCode = '265', strDescription = 'Methane', strProductCodeGroup = 'Blending Components', strNote = NULL
UNION ALL SELECT intProductCodeId = 274, strProductCode = '126', strDescription = 'Napthas', strProductCodeGroup = 'Blending Components', strNote = NULL
UNION ALL SELECT intProductCodeId = 275, strProductCode = '059', strDescription = 'Pentanes, including isopentanes', strProductCodeGroup = 'Blending Components', strNote = NULL
UNION ALL SELECT intProductCodeId = 276, strProductCode = '075', strDescription = 'Propylene', strProductCodeGroup = 'Blending Components', strNote = NULL
UNION ALL SELECT intProductCodeId = 277, strProductCode = '223', strDescription = 'Raffinates', strProductCodeGroup = 'Blending Components', strNote = NULL
UNION ALL SELECT intProductCodeId = 278, strProductCode = '121', strDescription = 'TAME', strProductCodeGroup = 'Blending Components', strNote = NULL
UNION ALL SELECT intProductCodeId = 279, strProductCode = '199', strDescription = 'Toluene', strProductCodeGroup = 'Blending Components', strNote = NULL
UNION ALL SELECT intProductCodeId = 280, strProductCode = '091', strDescription = 'Waste Oil', strProductCodeGroup = 'Blending Components', strNote = NULL
UNION ALL SELECT intProductCodeId = 281, strProductCode = '076', strDescription = 'Xylene', strProductCodeGroup = 'Blending Components', strNote = NULL
UNION ALL SELECT intProductCodeId = 282, strProductCode = 'B00', strDescription = 'Biodiesel - Undyed (100%)', strProductCodeGroup = 'Biodiesel - Undyed', strNote = NULL
UNION ALL SELECT intProductCodeId = 283, strProductCode = 'B11', strDescription = 'Biodiesel - Undyed (11%)', strProductCodeGroup = 'Biodiesel - Undyed', strNote = NULL
UNION ALL SELECT intProductCodeId = 284, strProductCode = 'D00', strDescription = 'Biodiesel - Dyed (100%)', strProductCodeGroup = 'Biodiesel - Dyed', strNote = NULL
UNION ALL SELECT intProductCodeId = 285, strProductCode = 'D11', strDescription = 'Biodiesel - Dyed (11%)', strProductCodeGroup = 'Biodiesel - Dyed', strNote = NULL
UNION ALL SELECT intProductCodeId = 286, strProductCode = '226', strDescription = 'High Sulfur Diesel - Dyed', strProductCodeGroup = 'Diesel Fuel - Dyed', strNote = NULL
UNION ALL SELECT intProductCodeId = 287, strProductCode = '227', strDescription = 'Low Sulfur Diesel - Dyed', strProductCodeGroup = 'Diesel Fuel - Dyed', strNote = NULL
UNION ALL SELECT intProductCodeId = 288, strProductCode = '231', strDescription = 'No. 1 Diesel - Dyed-MFT', strProductCodeGroup = 'Diesel Fuel - Dyed', strNote = NULL
UNION ALL SELECT intProductCodeId = 289, strProductCode = '232', strDescription = 'No. 1 Diesel - Dyed-SFT', strProductCodeGroup = 'Diesel Fuel - Dyed', strNote = NULL
UNION ALL SELECT intProductCodeId = 290, strProductCode = '153', strDescription = 'Diesel Fuel #4- Dyed', strProductCodeGroup = 'Diesel Fuel - Dyed', strNote = NULL
UNION ALL SELECT intProductCodeId = 291, strProductCode = '161', strDescription = 'Low Sulfur Diesel #1 - Undyed', strProductCodeGroup = 'Diesel Fuel - Undyed', strNote = NULL
UNION ALL SELECT intProductCodeId = 292, strProductCode = '167', strDescription = 'Low Sulfur Diesel #2 - Undyed', strProductCodeGroup = 'Diesel Fuel - Undyed', strNote = NULL
UNION ALL SELECT intProductCodeId = 293, strProductCode = '150', strDescription = 'No. 1 Fuel Oil - Undyed', strProductCodeGroup = 'Diesel Fuel - Undyed', strNote = NULL
UNION ALL SELECT intProductCodeId = 294, strProductCode = '154', strDescription = 'Diesel Fuel #4 - Undyed', strProductCodeGroup = 'Diesel Fuel - Undyed', strNote = NULL
UNION ALL SELECT intProductCodeId = 295, strProductCode = '282', strDescription = 'High Sulfur Diesel #1 - Undyed', strProductCodeGroup = 'Diesel Fuel - Undyed', strNote = NULL
UNION ALL SELECT intProductCodeId = 296, strProductCode = '283', strDescription = 'High Sulfur Diesel #2 - Undyed', strProductCodeGroup = 'Diesel Fuel - Undyed', strNote = NULL
UNION ALL SELECT intProductCodeId = 297, strProductCode = '224', strDescription = 'Compressed Natural Gas (CNG)', strProductCodeGroup = 'Natural Gas Products', strNote = NULL
UNION ALL SELECT intProductCodeId = 298, strProductCode = '225', strDescription = 'Liquid Natural Gas (LNG)', strProductCodeGroup = 'Natural Gas Products', strNote = NULL
UNION ALL SELECT intProductCodeId = 299, strProductCode = '152', strDescription = 'Heating Oil', strProductCodeGroup = 'Gasoline', strNote = NULL
UNION ALL SELECT intProductCodeId = 300, strProductCode = '130', strDescription = 'Jet Fuel', strProductCodeGroup = 'Gasoline', strNote = NULL
UNION ALL SELECT intProductCodeId = 301, strProductCode = '065', strDescription = 'Gasoline', strProductCodeGroup = 'Gasoline', strNote = NULL
UNION ALL SELECT intProductCodeId = 302, strProductCode = '145', strDescription = 'Low Sulfur Kerosene - Undyed- MFT', strProductCodeGroup = 'Kerosene - Undyed', strNote = NULL
UNION ALL SELECT intProductCodeId = 303, strProductCode = '146', strDescription = 'Low Sulfur Kerosene - Undyed- SFT', strProductCodeGroup = 'Kerosene - Undyed', strNote = NULL
UNION ALL SELECT intProductCodeId = 304, strProductCode = '147', strDescription = 'High Sulfur Kerosene - Undyed- MFT', strProductCodeGroup = 'Kerosene - Undyed', strNote = NULL
UNION ALL SELECT intProductCodeId = 305, strProductCode = '148', strDescription = 'High Sulfur Kerosene - Undyed- SFT', strProductCodeGroup = 'Kerosene - Undyed', strNote = NULL
UNION ALL SELECT intProductCodeId = 306, strProductCode = '073', strDescription = 'Low Sulfur Kerosene - Dyed', strProductCodeGroup = 'Kerosene - Dyed', strNote = NULL
UNION ALL SELECT intProductCodeId = 307, strProductCode = '074', strDescription = 'High Sulfur Kerosene - Dyed', strProductCodeGroup = 'Kerosene - Dyed', strNote = NULL
UNION ALL SELECT intProductCodeId = 308, strProductCode = '061', strDescription = 'Natural Gasoline', strProductCodeGroup = '', strNote = NULL
UNION ALL SELECT intProductCodeId = 309, strProductCode = '285', strDescription = 'Soy Oil', strProductCodeGroup = '', strNote = NULL
UNION ALL SELECT intProductCodeId = 310, strProductCode = '100', strDescription = 'Transmix - MFT', strProductCodeGroup = '', strNote = NULL
UNION ALL SELECT intProductCodeId = 311, strProductCode = '101', strDescription = 'Transmix - SFT', strProductCodeGroup = '', strNote = NULL
UNION ALL SELECT intProductCodeId = 312, strProductCode = '092', strDescription = 'Undefined products - MFT', strProductCodeGroup = '', strNote = NULL
UNION ALL SELECT intProductCodeId = 313, strProductCode = '093', strDescription = 'Undefined products - SFT', strProductCodeGroup = '', strNote = NULL
UNION ALL SELECT intProductCodeId = 314, strProductCode = 'E00', strDescription = 'Ethanol (100%) Blended', strProductCodeGroup = 'Alcohol', strNote = NULL
UNION ALL SELECT intProductCodeId = 315, strProductCode = 'E11', strDescription = 'Ethanol (11%) Blended', strProductCodeGroup = 'Alcohol', strNote = NULL
UNION ALL SELECT intProductCodeId = 2438, strProductCode = 'E10', strDescription = 'Ethanol (11%) Blended', strProductCodeGroup = 'Alcohol', strNote = 'This Product Code is now obsolete'

EXEC uspTFUpgradeProductCodes @TaxAuthorityCode = @TaxAuthorityCode, @ProductCodes = @ProductCodes


-- Terminal Control Numbers
/* Generate script for Terminal Control Numbers. Specify Tax Authority Id to filter out specific Terminal Control Numbers only.
select 'UNION ALL SELECT intTerminalControlNumberId = ' + CAST(intTerminalControlNumberId AS NVARCHAR(10)) 
	+ CASE WHEN strTerminalControlNumber IS NULL THEN ', strTerminalControlNumber = NULL' ELSE ', strTerminalControlNumber = ''' + strTerminalControlNumber + ''''  END
	+ CASE WHEN strName IS NULL THEN ', strName = NULL' ELSE ', strName = ''' + strName + ''''  END
	+ CASE WHEN strAddress IS NULL THEN ', strAddress = NULL' ELSE ', strAddress = ''' + strAddress + ''''  END
	+ CASE WHEN strCity IS NULL THEN ', strCity = NULL' ELSE ', strCity = ''' + strCity + '''' END 
	+ CASE WHEN dtmApprovedDate IS NULL THEN ', dtmApprovedDate = NULL' ELSE ', dtmApprovedDate = ''' + CAST(dtmApprovedDate AS NVARCHAR(50)) + '''' END 
	+ CASE WHEN strZip IS NULL THEN ', strZip = NULL' ELSE ', strZip = ''' + strZip + '''' END 
from tblTFTerminalControlNumber
where intTaxAuthorityId = @TaxAuthorityId
*/
DECLARE @TerminalControlNumbers AS TFTerminalControlNumbers

INSERT INTO @TerminalControlNumbers(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intTerminalControlNumberId = 374, strTerminalControlNumber = 'T-35-IN-3202', strName = 'Valero Terminaling & Distribution', strAddress = '1020 141st St', strCity = 'Hammond', dtmApprovedDate = NULL, strZip = '46320-'
UNION ALL SELECT intTerminalControlNumberId = 375, strTerminalControlNumber = 'T-35-IN-3203', strName = 'Buckeye Terminals, LLC - Granger', strAddress = '12694 Adams Rd', strCity = 'Granger', dtmApprovedDate = NULL, strZip = '46530'
UNION ALL SELECT intTerminalControlNumberId = 376, strTerminalControlNumber = 'T-35-IN-3204', strName = 'BP Products North America Inc', strAddress = '2500 N Tibbs Avenue', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46222'
UNION ALL SELECT intTerminalControlNumberId = 377, strTerminalControlNumber = 'T-35-IN-3205', strName = 'BP Products North America Inc', strAddress = '2530 Indianapolis Blvd.', strCity = 'Whiting', dtmApprovedDate = NULL, strZip = '46394'
UNION ALL SELECT intTerminalControlNumberId = 378, strTerminalControlNumber = 'T-35-IN-3207', strName = 'Marathon Evansville', strAddress = '2500 Broadway', strCity = 'Evansville', dtmApprovedDate = NULL, strZip = '47712'
UNION ALL SELECT intTerminalControlNumberId = 379, strTerminalControlNumber = 'T-35-IN-3208', strName = 'Marathon Huntington', strAddress = '4648 N. Meridian Road', strCity = 'Huntington', dtmApprovedDate = NULL, strZip = '46750'
UNION ALL SELECT intTerminalControlNumberId = 380, strTerminalControlNumber = 'T-35-IN-3209', strName = 'CITGO Petroleum Corporation - East Chicago', strAddress = '2500 East Chicago Ave', strCity = 'East Chicago', dtmApprovedDate = NULL, strZip = '46312'
UNION ALL SELECT intTerminalControlNumberId = 381, strTerminalControlNumber = 'T-35-IN-3210', strName = 'CITGO - Huntington', strAddress = '4393 N Meridian Rd US 24', strCity = 'Huntington', dtmApprovedDate = NULL, strZip = '46750'
UNION ALL SELECT intTerminalControlNumberId = 382, strTerminalControlNumber = 'T-35-IN-3211', strName = 'Gladieux Trading & Marketing Co.', strAddress = '4757 US 24 E', strCity = 'Huntington', dtmApprovedDate = NULL, strZip = '46750'
UNION ALL SELECT intTerminalControlNumberId = 383, strTerminalControlNumber = 'T-35-IN-3212', strName = 'TransMontaigne - Kentuckiana', strAddress = '20 Jackson St.', strCity = 'New Albany', dtmApprovedDate = NULL, strZip = '47150'
UNION ALL SELECT intTerminalControlNumberId = 384, strTerminalControlNumber = 'T-35-IN-3213', strName = 'TransMontaigne - Evansville', strAddress = '2630 Broadway', strCity = 'Evansville', dtmApprovedDate = NULL, strZip = '47712'
UNION ALL SELECT intTerminalControlNumberId = 385, strTerminalControlNumber = 'T-35-IN-3214', strName = 'Countrymark Cooperative LLP', strAddress = '1200 Refinery Road', strCity = 'Mount Vernon', dtmApprovedDate = NULL, strZip = '47620'
UNION ALL SELECT intTerminalControlNumberId = 386, strTerminalControlNumber = 'T-35-IN-3216', strName = 'HWRT Terminal - Seymour', strAddress = '9780 N US Hwy 31', strCity = 'Seymour', dtmApprovedDate = NULL, strZip = '47274'
UNION ALL SELECT intTerminalControlNumberId = 387, strTerminalControlNumber = 'T-35-IN-3218', strName = 'Marathon Hammond', strAddress = '4206 Columbia Avenue', strCity = 'Hammond', dtmApprovedDate = NULL, strZip = '46327'
UNION ALL SELECT intTerminalControlNumberId = 388, strTerminalControlNumber = 'T-35-IN-3219', strName = 'Marathon Indianapolis', strAddress = '4955 Robison Rd', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46268-1040'
UNION ALL SELECT intTerminalControlNumberId = 389, strTerminalControlNumber = 'T-35-IN-3221', strName = 'Marathon Muncie', strAddress = '2100 East State Road 28', strCity = 'Muncie', dtmApprovedDate = NULL, strZip = '47303-4773'
UNION ALL SELECT intTerminalControlNumberId = 390, strTerminalControlNumber = 'T-35-IN-3222', strName = 'Marathon Speedway', strAddress = '1304 Olin Ave', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46222-3294'
UNION ALL SELECT intTerminalControlNumberId = 391, strTerminalControlNumber = 'T-35-IN-3224', strName = 'ExxonMobil Oil Corp.', strAddress = '1527 141th Street', strCity = 'Hammond', dtmApprovedDate = NULL, strZip = '46327'
UNION ALL SELECT intTerminalControlNumberId = 392, strTerminalControlNumber = 'T-35-IN-3225', strName = 'Buckeye Terminals, LLC - East Chicago', strAddress = '400 East Columbus Dr', strCity = 'East Chicago', dtmApprovedDate = NULL, strZip = '46312'
UNION ALL SELECT intTerminalControlNumberId = 393, strTerminalControlNumber = 'T-35-IN-3226', strName = 'Buckeye Terminals, LLC - Raceway', strAddress = '3230 N Raceway Road', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46234'
UNION ALL SELECT intTerminalControlNumberId = 394, strTerminalControlNumber = 'T-35-IN-3227', strName = 'NuStar Terminals Operations Partnership L. P. - Indianapolis', strAddress = '3350 N. Raceway Rd.', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46234-1163'
UNION ALL SELECT intTerminalControlNumberId = 395, strTerminalControlNumber = 'T-35-IN-3228', strName = 'Buckeye Terminals, LLC - East Hammond', strAddress = '2400 Michigan St.', strCity = 'Hammond', dtmApprovedDate = NULL, strZip = '46320'
UNION ALL SELECT intTerminalControlNumberId = 396, strTerminalControlNumber = 'T-35-IN-3229', strName = 'Buckeye Terminals, LLC - Muncie', strAddress = '2000 East State Rd. 28', strCity = 'Muncie', dtmApprovedDate = NULL, strZip = '47303'
UNION ALL SELECT intTerminalControlNumberId = 397, strTerminalControlNumber = 'T-35-IN-3230', strName = 'Buckeye Terminals, LLC - Zionsville', strAddress = '5405 West 96th St.', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46268'
UNION ALL SELECT intTerminalControlNumberId = 398, strTerminalControlNumber = 'T-35-IN-3231', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '4691 N Meridian St', strCity = 'Huntington', dtmApprovedDate = NULL, strZip = '46750'
UNION ALL SELECT intTerminalControlNumberId = 399, strTerminalControlNumber = 'T-35-IN-3232', strName = 'ERPC Princeton', strAddress = 'CR 950 E', strCity = 'Oakland City', dtmApprovedDate = NULL, strZip = '47660'
UNION ALL SELECT intTerminalControlNumberId = 400, strTerminalControlNumber = 'T-35-IN-3234', strName = 'Lassus Bros. Oil, Inc. - Huntington', strAddress = '4413 North Meridian Rd', strCity = 'Huntington', dtmApprovedDate = NULL, strZip = '46750'
UNION ALL SELECT intTerminalControlNumberId = 401, strTerminalControlNumber = 'T-35-IN-3235', strName = 'Countrymark Cooperative LLP', strAddress = '17710 Mule Barn Road', strCity = 'Westfield', dtmApprovedDate = NULL, strZip = '46074'
UNION ALL SELECT intTerminalControlNumberId = 402, strTerminalControlNumber = 'T-35-IN-3236', strName = 'Countrymark Cooperative LLP', strAddress = '1765 West Logansport Rd.', strCity = 'Peru', dtmApprovedDate = NULL, strZip = '46970'
UNION ALL SELECT intTerminalControlNumberId = 403, strTerminalControlNumber = 'T-35-IN-3237', strName = 'Countrymark Cooperative LLP', strAddress = 'RR # 1, Box 119A', strCity = 'Switz City', dtmApprovedDate = NULL, strZip = '47465'
UNION ALL SELECT intTerminalControlNumberId = 404, strTerminalControlNumber = 'T-35-IN-3238', strName = 'Buckeye Terminals, LLC - Indianapolis', strAddress = '10700 E County Rd 300N', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46234'
UNION ALL SELECT intTerminalControlNumberId = 405, strTerminalControlNumber = 'T-35-IN-3239', strName = 'Marathon Mt Vernon', strAddress = '129 South Barter Street ', strCity = 'Mount Vernon', dtmApprovedDate = NULL, strZip = '47620-'
UNION ALL SELECT intTerminalControlNumberId = 406, strTerminalControlNumber = 'T-35-IN-3243', strName = 'CSX Transportation Inc', strAddress = '491 S. County Road 800 E.', strCity = 'Avon', dtmApprovedDate = NULL, strZip = '46123-'
UNION ALL SELECT intTerminalControlNumberId = 407, strTerminalControlNumber = 'T-35-IN-3245', strName = 'Norfolk Southern Railway Co End Terminal', strAddress = '2600 W. Lusher Rd.', strCity = 'Elkhart', dtmApprovedDate = NULL, strZip = '46516-'
UNION ALL SELECT intTerminalControlNumberId = 408, strTerminalControlNumber = 'T-35-IN-3246', strName = 'Buckeye Terminals, LLC - South Bend', strAddress = '20630 W. Ireland Rd.', strCity = 'South Bend', dtmApprovedDate = NULL, strZip = '46614-'
UNION ALL SELECT intTerminalControlNumberId = 409, strTerminalControlNumber = 'T-35-IN-3248', strName = 'West Shore Pipeline Company - Hammond', strAddress = '3900 White Oak Avenue', strCity = 'Hammond', dtmApprovedDate = NULL, strZip = '46320'
UNION ALL SELECT intTerminalControlNumberId = 410, strTerminalControlNumber = 'T-35-IN-3249', strName = 'NGL Supply Terminal Company LLC - Lebanon', strAddress = '550 West County Road 125 South', strCity = 'Lebanon', dtmApprovedDate = NULL, strZip = '46052'

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = @TaxAuthorityCode, @TerminalControlNumbers = @TerminalControlNumbers


-- Tax Category
/* Generate script for Tax Categories. Specify Tax Authority Id to filter out specific Tax Categories only.
select 'UNION ALL SELECT intTaxCategoryId = ' + CAST(intTaxCategoryId AS NVARCHAR(10))
	+ CASE WHEN strState IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + strState + ''''  END
	+ CASE WHEN strTaxCategory IS NULL THEN ', strTaxCategory = NULL' ELSE ', strTaxCategory = ''' + strTaxCategory + ''''  END
from tblTFTaxCategory
where intTaxAuthorityId = @TaxAuthorityId
*/
DECLARE @TaxCategories AS TFTaxCategory

INSERT INTO @TaxCategories(
	intTaxCategoryId
	, strState
	, strTaxCategory
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intTaxCategoryId = 1, strState = 'IN', strTaxCategory = 'IN Excise Tax Gasoline'
UNION ALL SELECT intTaxCategoryId = 2, strState = 'IN', strTaxCategory = 'IN Excise Tax Diesel Clear'
UNION ALL SELECT intTaxCategoryId = 3, strState = 'IN', strTaxCategory = 'IN Inspection Fee'
UNION ALL SELECT intTaxCategoryId = 4, strState = 'IN', strTaxCategory = 'IN Gasoline Use Tax (GUT)'

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = @TaxAuthorityCode, @TaxCategories = @TaxCategories


-- Reporting Component
/* Generate script for Reporting Components. Specify Tax Authority Id to filter out specific Reporting Components only.
select 'UNION ALL SELECT intReportingComponentId = ' + CAST(intReportingComponentId AS NVARCHAR(10))
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strFormName IS NULL THEN ', strFormName = NULL' ELSE ', strFormName = ''' + strFormName + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strScheduleName IS NULL THEN ', strScheduleName = NULL' ELSE ', strScheduleName = ''' + strScheduleName + '''' END 
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN strNote IS NULL THEN ', strNote = NULL' ELSE ', strNote = ''' + strNote + '''' END
	+ CASE WHEN strTransactionType IS NULL THEN ', strTransactionType = NULL' ELSE ', strTransactionType = ''' + strTransactionType + '''' END
	+ CASE WHEN intPositionId IS NULL THEN ', intPositionId = NULL' ELSE ', intPositionId = ' + CAST(intPositionId AS NVARCHAR(10)) END
	+ CASE WHEN strSPInventory IS NULL THEN ', strSPInventory = NULL' ELSE ', strSPInventory = ''' + strSPInventory + '''' END
	+ CASE WHEN strSPInvoice IS NULL THEN ', strSPInvoice = NULL' ELSE ', strSPInvoice = ''' + strSPInvoice + '''' END
	+ CASE WHEN strSPRunReport IS NULL THEN ', strSPRunReport = NULL' ELSE ', strSPRunReport = ''' + strSPRunReport + '''' END
from tblTFReportingComponent
where intTaxAuthorityId = @TaxAuthorityId
*/
DECLARE @ReportingComponent AS TFReportingComponent

INSERT INTO @ReportingComponent(
	intReportingComponentId
	, strFormCode
	, strFormName
	, strScheduleCode
	, strScheduleName
	, strType
	, strNote
	, strTransactionType
	, intPositionId
	, strSPInventory
	, strSPInvoice
	, strSPRunReport
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intReportingComponentId = 1, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '1A', strScheduleName = 'Gallons Received Tax Paid (Gasoline Return Only)', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = '', strTransactionType = 'Inventory', intPositionId = 10, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 2, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '1A', strScheduleName = 'Gallons Received Tax Paid (Gasoline Return Only)', strType = 'K-1 / K-2 Kerosene', strNote = '', strTransactionType = 'Inventory', intPositionId = 20, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 3, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '1A', strScheduleName = 'Gallons Received Tax Paid (Gasoline Return Only)', strType = 'All Other Products', strNote = '', strTransactionType = 'Inventory', intPositionId = 30, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 4, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '2', strScheduleName = 'Gallons Received from Licensed Distributor or Oil Inspection Distributor, Tax Unpaid (Gasoline Only)', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = '', strTransactionType = 'Inventory', intPositionId = 40, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 5, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '2', strScheduleName = 'Gallons Received from Licensed Distributor or Oil Inspection Distributor, Tax Unpaid (Gasoline Only)', strType = 'K-1 / K-2 Kerosene', strNote = '', strTransactionType = 'Inventory', intPositionId = 50, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 6, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '2', strScheduleName = 'Gallons Received from Licensed Distributor or Oil Inspection Distributor, Tax Unpaid (Gasoline Only)', strType = 'All Other Products', strNote = '', strTransactionType = 'Inventory', intPositionId = 60, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 7, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '2K', strScheduleName = 'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = '', strTransactionType = 'Inventory', intPositionId = 70, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 8, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '2K', strScheduleName = 'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose', strType = 'K-1 / K-2 Kerosene', strNote = '', strTransactionType = 'Inventory', intPositionId = 80, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 9, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '2K', strScheduleName = 'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose', strType = 'All Other Products', strNote = '', strTransactionType = 'Inventory', intPositionId = 90, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 10, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '2X', strScheduleName = 'Gallons Received from Distributor on Exchange (Gasoline Only)', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = '', strTransactionType = 'Inventory', intPositionId = 100, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 11, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '2X', strScheduleName = 'Gallons Received from Distributor on Exchange (Gasoline Only)', strType = 'K-1 / K-2 Kerosene', strNote = '', strTransactionType = 'Inventory', intPositionId = 110, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 12, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '2X', strScheduleName = 'Gallons Received from Distributor on Exchange (Gasoline Only)', strType = 'All Other Products', strNote = '', strTransactionType = 'Inventory', intPositionId = 120, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 13, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '3', strScheduleName = 'Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = '', strTransactionType = 'Inventory', intPositionId = 130, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 14, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '3', strScheduleName = 'Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid', strType = 'K-1 / K-2 Kerosene', strNote = '', strTransactionType = 'Inventory', intPositionId = 140, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 15, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '3', strScheduleName = 'Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid', strType = 'All Other Products', strNote = '', strTransactionType = 'Inventory', intPositionId = 150, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 16, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '4', strScheduleName = 'Gallons Imported into Own Storage  (Gasoline Only)', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = '', strTransactionType = 'Inventory', intPositionId = 160, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 17, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '4', strScheduleName = 'Gallons Imported into Own Storage  (Gasoline Only)', strType = 'K-1 / K-2 Kerosene', strNote = '', strTransactionType = 'Inventory', intPositionId = 170, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 18, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '4', strScheduleName = 'Gallons Imported into Own Storage  (Gasoline Only)', strType = 'All Other Products', strNote = '', strTransactionType = 'Inventory', intPositionId = 180, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 19, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '5', strScheduleName = 'Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = '', strTransactionType = 'Invoice', intPositionId = 190, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 20, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '5', strScheduleName = 'Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used', strType = 'K-1 / K-2 Kerosene', strNote = '', strTransactionType = 'Invoice', intPositionId = 200, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 21, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '5', strScheduleName = 'Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used', strType = 'All Other Products', strNote = '', strTransactionType = 'Invoice', intPositionId = 210, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 22, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '6D', strScheduleName = 'Gallons Sold to Licensed Distributors, Tax Not Collected (Gasoline Only)', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = '', strTransactionType = 'Invoice', intPositionId = 220, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 23, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '6D', strScheduleName = 'Gallons Sold to Licensed Distributors, Tax Not Collected (Gasoline Only)', strType = 'K-1 / K-2 Kerosene', strNote = '', strTransactionType = 'Invoice', intPositionId = 230, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 24, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '6D', strScheduleName = 'Gallons Sold to Licensed Distributors, Tax Not Collected (Gasoline Only)', strType = 'All Other Products', strNote = '', strTransactionType = 'Invoice', intPositionId = 240, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 25, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '6X', strScheduleName = 'Gallons Disbursed on Exchange', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = '', strTransactionType = 'Invoice', intPositionId = 250, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 26, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '6X', strScheduleName = 'Gallons Disbursed on Exchange', strType = 'K-1 / K-2 Kerosene', strNote = '', strTransactionType = 'Invoice', intPositionId = 260, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 27, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '6X', strScheduleName = 'Gallons Disbursed on Exchange', strType = 'All Other Products', strNote = '', strTransactionType = 'Invoice', intPositionId = 270, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 28, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7MI', strScheduleName = 'Gallons Exported to State of MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = '', strTransactionType = 'Invoice', intPositionId = 280, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 29, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7MI', strScheduleName = 'Gallons Exported to State of MI', strType = 'K-1 / K-2 Kerosene', strNote = '', strTransactionType = 'Invoice', intPositionId = 290, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 30, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7MI', strScheduleName = 'Gallons Exported to State of MI', strType = 'All Other Products', strNote = '', strTransactionType = 'Invoice', intPositionId = 300, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 31, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '8', strScheduleName = 'Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = '', strTransactionType = 'Invoice', intPositionId = 370, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 32, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '8', strScheduleName = 'Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt', strType = 'K-1 / K-2 Kerosene', strNote = '', strTransactionType = 'Invoice', intPositionId = 380, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 33, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '8', strScheduleName = 'Gallons of Undyed Special Fuel, Gasoline and Kerosene sold to the US Government Tax Exempt', strType = 'All Other Products', strNote = '', strTransactionType = 'Invoice', intPositionId = 390, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 34, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '10A', strScheduleName = 'Gallons Delivered to Marina Fuel Dealers', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = '', strTransactionType = 'Invoice', intPositionId = 460, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 37, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '10B', strScheduleName = 'Gallons Delivered to Aviation Fuel Dealers', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = '', strTransactionType = 'Invoice', intPositionId = 490, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 40, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '', strScheduleName = 'Main Form', strType = '', strNote = 'Form MF-360', strTransactionType = '', intPositionId = 520, strSPInventory = '', strSPInvoice = '', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 41, strFormCode = 'GT-103', strFormName = 'Recap of Gasoline Use Tax by Distributors', strScheduleCode = '1R', strScheduleName = 'Receipt Schedule', strType = 'Gasoline', strNote = '', strTransactionType = 'Inventory', intPositionId = 530, strSPInventory = 'uspTFGT103InventoryTax', strSPInvoice = 'uspTFGT103InvoiceTax', strSPRunReport = 'uspTFGenerateGT103'
UNION ALL SELECT intReportingComponentId = 42, strFormCode = 'GT-103', strFormName = 'Recap of Gasoline Use Tax by Distributors', strScheduleCode = '1R', strScheduleName = 'Receipt Schedule', strType = 'Gasohol', strNote = '', strTransactionType = 'Inventory', intPositionId = 540, strSPInventory = 'uspTFGT103InventoryTax', strSPInvoice = 'uspTFGT103InvoiceTax', strSPRunReport = 'uspTFGenerateGT103'
UNION ALL SELECT intReportingComponentId = 43, strFormCode = 'GT-103', strFormName = 'Recap of Gasoline Use Tax by Distributors', strScheduleCode = '2D', strScheduleName = 'Disbursement Schedule', strType = 'Gasoline', strNote = '', strTransactionType = 'Invoice', intPositionId = 541, strSPInventory = 'uspTFGT103InventoryTax', strSPInvoice = 'uspTFGT103InvoiceTax', strSPRunReport = 'uspTFGenerateGT103'
UNION ALL SELECT intReportingComponentId = 44, strFormCode = 'GT-103', strFormName = 'Recap of Gasoline Use Tax by Distributors', strScheduleCode = '2D', strScheduleName = 'Disbursement Schedule', strType = 'Gasohol', strNote = '', strTransactionType = 'Invoice', intPositionId = 542, strSPInventory = 'uspTFGT103InventoryTax', strSPInvoice = 'uspTFGT103InvoiceTax', strSPRunReport = 'uspTFGenerateGT103'
UNION ALL SELECT intReportingComponentId = 45, strFormCode = 'GT-103', strFormName = 'Recap of Gasoline Use Tax by Distributors', strScheduleCode = '', strScheduleName = 'Main Form', strType = '', strNote = 'Form GT-103', strTransactionType = '', intPositionId = 550, strSPInventory = '', strSPInvoice = '', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 46, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '1', strScheduleName = 'Gallons Received Tax Paid (Special Fuel Returns Only)', strType = '', strNote = '', strTransactionType = 'Inventory', intPositionId = 560, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900'
UNION ALL SELECT intReportingComponentId = 47, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '2E', strScheduleName = 'Gallons Received for Export (Special Fuel Exporters Only)', strType = '', strNote = '', strTransactionType = 'Inventory', intPositionId = 570, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900'
UNION ALL SELECT intReportingComponentId = 48, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '2K', strScheduleName = 'Gallons of Non-Taxable Fuel Received and Sold or Used for a Taxable Purpose', strType = '', strNote = '', strTransactionType = 'Inventory', intPositionId = 580, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900'
UNION ALL SELECT intReportingComponentId = 49, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '3', strScheduleName = 'Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid', strType = '', strNote = '', strTransactionType = 'Inventory', intPositionId = 590, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900'
UNION ALL SELECT intReportingComponentId = 50, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '5', strScheduleName = 'Gallons Delivered, Tax Collected and Gallons Blended or Dyed Fuel Used', strType = '', strNote = '', strTransactionType = 'Invoice', intPositionId = 600, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900'
UNION ALL SELECT intReportingComponentId = 51, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '6', strScheduleName = 'Gallons Delivered Via Rail, Pipeline or Vessel to Licensed Suppliers, Tax Not Collected (Special Fuel)', strType = '', strNote = '', strTransactionType = 'Invoice', intPositionId = 610, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900'
UNION ALL SELECT intReportingComponentId = 52, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '6X', strScheduleName = 'Gallons Disbursed on Exchange', strType = '', strNote = '', strTransactionType = 'Invoice', intPositionId = 620, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900'
UNION ALL SELECT intReportingComponentId = 53, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7IL', strScheduleName = 'Gallons Exported to State of IL', strType = '', strNote = '', strTransactionType = 'Invoice', intPositionId = 630, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900'
UNION ALL SELECT intReportingComponentId = 54, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7AIL', strScheduleName = 'Special Fuel Sold to Unlicensed Exporters for Export to State of IL (IL Tax Collected)', strType = '', strNote = '', strTransactionType = 'Invoice', intPositionId = 634, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900'
UNION ALL SELECT intReportingComponentId = 55, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7BIL', strScheduleName = 'Special Fuel Sold to Licensed Exporters for Export to State of IL', strType = '', strNote = '', strTransactionType = 'Invoice', intPositionId = 638, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900'
UNION ALL SELECT intReportingComponentId = 56, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '8', strScheduleName = 'Gallons of Undyed Special Fuel, Gasoline and Kerosene Sold to the US Government Tax Exempt', strType = '', strNote = '', strTransactionType = 'Invoice', intPositionId = 660, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900'
UNION ALL SELECT intReportingComponentId = 57, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '10', strScheduleName = 'Gallons Sold of Tax Exempt Dyed Fuel', strType = '', strNote = '', strTransactionType = 'Invoice', intPositionId = 670, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900'
UNION ALL SELECT intReportingComponentId = 58, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '11', strScheduleName = 'Diversion Corrections', strType = '', strNote = '', strTransactionType = 'Invoice', intPositionId = 680, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900'
UNION ALL SELECT intReportingComponentId = 59, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '', strScheduleName = 'Main Form', strType = '', strNote = 'Form SF-900', strTransactionType = '', intPositionId = 690, strSPInventory = '', strSPInvoice = '', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 60, strFormCode = 'SF-401', strFormName = 'Transporters Monthly Tax Return', strScheduleCode = '1A', strScheduleName = 'Exports', strType = 'Special Fuel', strNote = 'Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel', strTransactionType = 'Invoice', intPositionId = 700, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFSF401InvoiceTax', strSPRunReport = 'uspTFGenerateSF401'
UNION ALL SELECT intReportingComponentId = 61, strFormCode = 'SF-401', strFormName = 'Transporters Monthly Tax Return', strScheduleCode = '1A', strScheduleName = 'Exports', strType = 'Gasoline', strNote = 'Gasoline, Gasohol', strTransactionType = 'Invoice', intPositionId = 710, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFSF401InvoiceTax', strSPRunReport = 'uspTFGenerateSF401'
UNION ALL SELECT intReportingComponentId = 62, strFormCode = 'SF-401', strFormName = 'Transporters Monthly Tax Return', strScheduleCode = '1A', strScheduleName = 'Exports', strType = 'Other Products', strNote = 'Jet Fuel, Jerosene', strTransactionType = 'Invoice', intPositionId = 720, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFSF401InvoiceTax', strSPRunReport = 'uspTFGenerateSF401'
UNION ALL SELECT intReportingComponentId = 63, strFormCode = 'SF-401', strFormName = 'Transporters Monthly Tax Return', strScheduleCode = '2A', strScheduleName = 'Imports', strType = 'Special Fuel', strNote = 'Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel', strTransactionType = 'Invoice', intPositionId = 730, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFSF401InvoiceTax', strSPRunReport = 'uspTFGenerateSF401'
UNION ALL SELECT intReportingComponentId = 64, strFormCode = 'SF-401', strFormName = 'Transporters Monthly Tax Return', strScheduleCode = '2A', strScheduleName = 'Imports', strType = 'Gasoline', strNote = 'Gasoline, Gasohol', strTransactionType = 'Invoice', intPositionId = 750, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFSF401InvoiceTax', strSPRunReport = 'uspTFGenerateSF401'
UNION ALL SELECT intReportingComponentId = 65, strFormCode = 'SF-401', strFormName = 'Transporters Monthly Tax Return', strScheduleCode = '2A', strScheduleName = 'Imports', strType = 'Other Products', strNote = 'Jet Fuel, Jerosene', strTransactionType = 'Invoice', intPositionId = 760, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFSF401InvoiceTax', strSPRunReport = 'uspTFGenerateSF401'
UNION ALL SELECT intReportingComponentId = 66, strFormCode = 'SF-401', strFormName = 'Transporters Monthly Tax Return', strScheduleCode = '3A', strScheduleName = 'In-State Transfers', strType = 'Special Fuel', strNote = 'Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel', strTransactionType = 'Invoice', intPositionId = 770, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFSF401InvoiceTax', strSPRunReport = 'uspTFGenerateSF401'
UNION ALL SELECT intReportingComponentId = 67, strFormCode = 'SF-401', strFormName = 'Transporters Monthly Tax Return', strScheduleCode = '3A', strScheduleName = 'In-State Transfers', strType = 'Gasoline', strNote = 'Gasoline, Gasohol', strTransactionType = 'Invoice', intPositionId = 780, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFSF401InvoiceTax', strSPRunReport = 'uspTFGenerateSF401'
UNION ALL SELECT intReportingComponentId = 68, strFormCode = 'SF-401', strFormName = 'Transporters Monthly Tax Return', strScheduleCode = '3A', strScheduleName = 'In-State Transfers', strType = 'Other Products', strNote = 'Jet Fuel, Jerosene', strTransactionType = 'Invoice', intPositionId = 790, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFSF401InvoiceTax', strSPRunReport = 'uspTFGenerateSF401'
UNION ALL SELECT intReportingComponentId = 69, strFormCode = 'SF-401', strFormName = 'Transporters Monthly Tax Return', strScheduleCode = '', strScheduleName = 'Main Form', strType = '', strNote = 'Form SF-401', strTransactionType = NULL, intPositionId = 795, strSPInventory = NULL, strSPInvoice = NULL, strSPRunReport = NULL
UNION ALL SELECT intReportingComponentId = 70, strFormCode = 'EDI', strFormName = 'Electronic file', strScheduleCode = '', strScheduleName = 'IN EDI file', strType = 'EDI', strNote = '', strTransactionType = '', intPositionId = 800, strSPInventory = '', strSPInvoice = '', strSPRunReport = ''
UNION ALL SELECT intReportingComponentId = 71, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7KY', strScheduleName = 'Gallons Exported to State of KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = '', strTransactionType = 'Invoice', intPositionId = 310, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 72, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7KY', strScheduleName = 'Gallons Exported to State of KY', strType = 'K-1 / K-2 Kerosene', strNote = '', strTransactionType = 'Invoice', intPositionId = 320, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 73, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7KY', strScheduleName = 'Gallons Exported to State of KY', strType = 'All Other Products', strNote = '', strTransactionType = 'Invoice', intPositionId = 330, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 74, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7IL', strScheduleName = 'Gallons Exported to State of IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = '', strTransactionType = 'Invoice', intPositionId = 340, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 75, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7IL', strScheduleName = 'Gallons Exported to State of IL', strType = 'K-1 / K-2 Kerosene', strNote = '', strTransactionType = 'Invoice', intPositionId = 350, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 76, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7IL', strScheduleName = 'Gallons Exported to State of IL', strType = 'All Other Products', strNote = '', strTransactionType = 'Invoice', intPositionId = 360, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 77, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7OH', strScheduleName = 'Gallons Exported to State of OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strNote = '', strTransactionType = 'Invoice', intPositionId = 365, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 78, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7OH', strScheduleName = 'Gallons Exported to State of OH', strType = 'K-1 / K-2 Kerosene', strNote = '', strTransactionType = 'Invoice', intPositionId = 366, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 79, strFormCode = 'MF-360', strFormName = 'Consolidated Gasoline Monthly Tax Return', strScheduleCode = '7OH', strScheduleName = 'Gallons Exported to State of OH', strType = 'All Other Products', strNote = '', strTransactionType = 'Invoice', intPositionId = 367, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateMF360'
UNION ALL SELECT intReportingComponentId = 80, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7KY', strScheduleName = 'Gallons Exported to State of KY', strType = '', strNote = '', strTransactionType = 'Invoice', intPositionId = 631, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900'
UNION ALL SELECT intReportingComponentId = 81, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7MI', strScheduleName = 'Gallons Exported to State of MI', strType = '', strNote = '', strTransactionType = 'Invoice', intPositionId = 632, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900'
UNION ALL SELECT intReportingComponentId = 82, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7OH', strScheduleName = 'Gallons Exported to State of OH', strType = '', strNote = '', strTransactionType = 'Invoice', intPositionId = 633, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900'
UNION ALL SELECT intReportingComponentId = 83, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7AKY', strScheduleName = 'Special Fuel Sold to Unlicensed Exporters for Export to State of KY (KY Tax Collected)', strType = '', strNote = '', strTransactionType = 'Invoice', intPositionId = 635, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900'
UNION ALL SELECT intReportingComponentId = 84, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7AMI', strScheduleName = 'Special Fuel Sold to Unlicensed Exporters for Export to State of MI (MI Tax Collected)', strType = '', strNote = '', strTransactionType = 'Invoice', intPositionId = 636, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900'
UNION ALL SELECT intReportingComponentId = 85, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7AOH', strScheduleName = 'Special Fuel Sold to Unlicensed Exporters for Export to State of OH (OH Tax Collected)', strType = '', strNote = '', strTransactionType = 'Invoice', intPositionId = 637, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900'
UNION ALL SELECT intReportingComponentId = 86, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7BKY', strScheduleName = 'Special Fuel Sold to Licensed Exporters for Export to State of KY', strType = '', strNote = '', strTransactionType = 'Invoice', intPositionId = 639, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900'
UNION ALL SELECT intReportingComponentId = 87, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7BMI', strScheduleName = 'Special Fuel Sold to Licensed Exporters for Export to State of MI', strType = '', strNote = '', strTransactionType = 'Invoice', intPositionId = 640, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900'
UNION ALL SELECT intReportingComponentId = 88, strFormCode = 'SF-900', strFormName = 'Consolidated Special Fuel Monthly Tax Return', strScheduleCode = '7BOH', strScheduleName = 'Special Fuel Sold to Licensed Exporters for Export to State of OH', strType = '', strNote = '', strTransactionType = 'Invoice', intPositionId = 641, strSPInventory = 'uspTFGetInventoryTax', strSPInvoice = 'uspTFGetInvoiceTax', strSPRunReport = 'uspTFGenerateSF900'

EXEC uspTFUpgradeReportingComponents @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponent = @ReportingComponent


-- Tax Criteria
/* Generate script for Tax Criteria. Specify Tax Authority Id to filter out specific Tax Criteria only.
select 'UNION ALL SELECT intTaxCriteriaId = ' + CAST(intReportingComponentCriteriaId AS NVARCHAR(10))
	+ CASE WHEN TaxCat.strTaxCategory IS NULL THEN ', strTaxCategory = NULL' ELSE ', strTaxCategory = ''' + TaxCat.strTaxCategory + ''''  END
	+ CASE WHEN TaxCat.strState IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + TaxCat.strState + ''''  END
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN strCriteria IS NULL THEN ', strCriteria = NULL' ELSE ', strCriteria = ''' + strCriteria + '''' END
from tblTFReportingComponentCriteria TaxCrit
left join tblTFTaxCategory TaxCat ON TaxCat.intTaxCategoryId = TaxCrit.intTaxCategoryId
left join tblTFReportingComponent RC ON RC.intReportingComponentId = TaxCrit.intReportingComponentId
where RC.intTaxAuthorityId = @TaxAuthorityId and TaxCat.intTaxAuthorityId = @TaxAuthorityId
*/
DECLARE @TaxCriteria AS TFTaxCriteria

INSERT INTO @TaxCriteria(
	intTaxCriteriaId
	, strTaxCategory
	, strState
	, strFormCode
	, strScheduleCode
	, strType
	, strCriteria
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intTaxCriteriaId = 1, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 2, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 3, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 4, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 5, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 6, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 7, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 8, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 9, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 10, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 11, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 12, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 13, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 14, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 15, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 16, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 17, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 18, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 19, strTaxCategory = 'IN Excise Tax Diesel Clear', strState = 'IN', strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 20, strTaxCategory = 'IN Excise Tax Diesel Clear', strState = 'IN', strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 21, strTaxCategory = 'IN Excise Tax Diesel Clear', strState = 'IN', strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 22, strTaxCategory = 'IN Excise Tax Diesel Clear', strState = 'IN', strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 23, strTaxCategory = 'IN Excise Tax Diesel Clear', strState = 'IN', strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strCriteria = '= 0'

EXEC uspTFUpgradeTaxCriteria @TaxAuthorityCode = @TaxAuthorityCode, @TaxCriteria = @TaxCriteria


-- Reporting Component - Base
/* Generate script for Valid Product Codes. Specify Tax Authority Id to filter out specific Valid Product Codes only.
select 'UNION ALL SELECT intValidProductCodeId = ' + CAST(intReportingComponentProductCodeId AS NVARCHAR(10))
	+ CASE WHEN PC.strProductCode IS NULL THEN ', strProductCode = NULL' ELSE ', strProductCode = ''' + PC.strProductCode + ''''  END
	+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN RC.strType IS NULL THEN ', strType = ''''' ELSE ', strType = ''' + RC.strType + '''' END
from tblTFReportingComponentProductCode RCPC
left join tblTFProductCode PC ON PC.intProductCodeId= RCPC.intProductCodeId
left join tblTFReportingComponent RC ON RC.intReportingComponentId = RCPC.intReportingComponentId
where RC.intTaxAuthorityId = @TaxAuthorityId
*/
/* Generate script for Valid Origin States. Specify Tax Authority Id to filter out specific Valid Origin States only.
select 'UNION ALL SELECT intValidOriginStateId = ' + CAST(intReportingComponentOriginStateId AS NVARCHAR(10))
	+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + RC.strFormCode + ''''  END
	+ CASE WHEN RC.strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + RC.strScheduleCode + ''''  END
	+ CASE WHEN RC.strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + RC.strType + '''' END
	+ CASE WHEN ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS + ''''  END
	+ CASE WHEN RCOS.strType IS NULL THEN ', strStatus = NULL' ELSE ', strStatus = ''' + RCOS.strType + ''''  END
from tblTFReportingComponentOriginState RCOS
left join tblTFOriginDestinationState ODS ON ODS.intOriginDestinationStateId= RCOS.intOriginDestinationStateId
left join tblTFReportingComponent RC ON RC.intReportingComponentId = RCOS.intReportingComponentId
where RC.intTaxAuthorityId = @TaxAuthorityId
*/
/* Generate script for Valid Destination States. Specify Tax Authority Id to filter out specific Valid Destination States only.
select 'UNION ALL SELECT intValidDestinationStateId = ' + CAST(intReportingComponentDestinationStateId AS NVARCHAR(10))
	+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + RC.strFormCode + ''''  END
	+ CASE WHEN RC.strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + RC.strScheduleCode + ''''  END
	+ CASE WHEN RC.strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + RC.strType + '''' END
	+ CASE WHEN ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS + ''''  END
	+ CASE WHEN RCDS.strType IS NULL THEN ', strStatus = NULL' ELSE ', strStatus = ''' + RCDS.strType + ''''  END
from tblTFReportingComponentDestinationState RCDS
left join tblTFOriginDestinationState ODS ON ODS.intOriginDestinationStateId= RCDS.intOriginDestinationStateId
left join tblTFReportingComponent RC ON RC.intReportingComponentId = RCDS.intReportingComponentId
where RC.intTaxAuthorityId = @TaxAuthorityId
*/
DECLARE @ValidProductCodes AS TFValidProductCodes
DECLARE @ValidOriginStates AS TFValidOriginStates
DECLARE @ValidDestinationStates AS TFValidDestinationStates

INSERT INTO @ValidProductCodes(
	intValidProductCodeId
	, strProductCode
	, strFormCode
	, strScheduleCode
	, strType
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intValidProductCodeId = 1, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 2, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 3, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 4, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 5, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 6, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 7, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 1166, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 8, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 9, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 10, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 11, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 12, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 13, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 14, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 15, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 16, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 17, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 18, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 19, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 20, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 21, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 22, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 23, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 24, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 25, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 26, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 27, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 28, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 29, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 30, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 31, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 32, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 33, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 34, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 35, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 36, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 37, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 38, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 39, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 1168, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 40, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 41, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 42, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 43, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 44, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 45, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 46, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 47, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 48, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 49, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 50, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 51, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 52, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 53, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 54, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 55, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 56, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 57, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 58, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 59, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 60, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 61, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 62, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 63, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 64, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 65, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 66, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 67, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 68, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 69, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 70, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 71, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 1169, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 72, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 73, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 74, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 75, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 76, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 77, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 78, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 79, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 80, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 81, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 82, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 83, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 84, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 85, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 86, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 87, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 88, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 89, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 90, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 91, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 92, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 93, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 94, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 95, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 96, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 97, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 98, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 99, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 100, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 101, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 102, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 103, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 1170, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 104, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 105, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 106, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 107, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 108, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 109, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 110, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 111, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 112, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 113, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 114, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 115, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 116, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 117, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 118, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 119, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 120, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 121, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 122, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 123, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 124, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 125, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 126, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 127, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 128, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 129, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 130, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 131, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 132, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 133, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 134, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 135, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 1171, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 136, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 137, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 138, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 139, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 140, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 141, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 142, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 143, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 144, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 145, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 146, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 147, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 148, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 149, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 150, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 151, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 152, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 153, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 154, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 155, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 156, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 157, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 158, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 159, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 160, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 161, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 162, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 163, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 164, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 165, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 166, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 167, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 1172, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 168, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 169, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 170, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 171, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 172, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 173, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 174, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 175, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 176, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 177, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 178, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 179, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 180, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 181, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 182, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 183, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 184, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 185, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 186, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 187, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 188, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 189, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 190, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 191, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 192, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 193, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 194, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 195, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 196, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 197, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 198, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 199, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 1173, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 200, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 201, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 202, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 203, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 204, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 205, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 206, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 207, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 208, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 209, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 210, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 211, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 212, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 213, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 214, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 215, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 216, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 217, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 218, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 219, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 220, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 221, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 222, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 223, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 224, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 225, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 226, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 227, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 228, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 229, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 230, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 231, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 1174, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 232, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 233, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 234, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 235, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 236, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 237, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 238, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 239, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 240, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 241, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 242, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 243, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 244, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 245, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 246, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 247, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 248, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 249, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 250, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 251, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 252, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 253, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 254, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 255, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 256, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 257, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 258, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 259, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 260, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 261, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 262, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 263, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 1175, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 264, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 265, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 266, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 267, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 268, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 269, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 270, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 271, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 272, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 273, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 274, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 275, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 276, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 277, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 278, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 279, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 280, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 281, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 282, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 283, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 284, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 285, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 286, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 287, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 288, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 289, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 290, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 291, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 292, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 293, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 294, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 295, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 1176, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 296, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 297, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 298, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 299, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 300, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 301, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 302, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 303, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 304, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 305, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 306, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 307, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 308, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 309, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 310, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 311, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 312, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 313, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 314, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 315, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 316, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 317, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 318, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 319, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 320, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 321, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 322, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 323, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 324, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 325, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 326, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 327, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 1180, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 328, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 329, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 330, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 331, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 332, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 333, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 334, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 335, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 336, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 337, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 338, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 339, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 340, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 341, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 342, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 343, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 344, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 345, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 346, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 347, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 348, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 349, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 350, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 351, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 352, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 353, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 354, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 355, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 356, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 357, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 358, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 359, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 1181, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 360, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 361, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 362, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 363, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 364, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 365, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 366, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 1182, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 367, strProductCode = '065', strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 368, strProductCode = '061', strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 369, strProductCode = 'M00', strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol'
UNION ALL SELECT intValidProductCodeId = 370, strProductCode = 'M11', strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol'
UNION ALL SELECT intValidProductCodeId = 371, strProductCode = 'E00', strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol'
UNION ALL SELECT intValidProductCodeId = 372, strProductCode = 'E11', strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol'
UNION ALL SELECT intValidProductCodeId = 1183, strProductCode = 'E10', strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol'
UNION ALL SELECT intValidProductCodeId = 373, strProductCode = '065', strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 374, strProductCode = '061', strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 375, strProductCode = 'M00', strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol'
UNION ALL SELECT intValidProductCodeId = 376, strProductCode = 'M11', strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol'
UNION ALL SELECT intValidProductCodeId = 377, strProductCode = 'E00', strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol'
UNION ALL SELECT intValidProductCodeId = 378, strProductCode = 'E11', strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol'
UNION ALL SELECT intValidProductCodeId = 1184, strProductCode = 'E10', strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol'
UNION ALL SELECT intValidProductCodeId = 379, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '1', strType = ''
UNION ALL SELECT intValidProductCodeId = 380, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '1', strType = ''
UNION ALL SELECT intValidProductCodeId = 381, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '1', strType = ''
UNION ALL SELECT intValidProductCodeId = 382, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '1', strType = ''
UNION ALL SELECT intValidProductCodeId = 383, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '1', strType = ''
UNION ALL SELECT intValidProductCodeId = 384, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '1', strType = ''
UNION ALL SELECT intValidProductCodeId = 385, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '1', strType = ''
UNION ALL SELECT intValidProductCodeId = 386, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '1', strType = ''
UNION ALL SELECT intValidProductCodeId = 387, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '1', strType = ''
UNION ALL SELECT intValidProductCodeId = 388, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '1', strType = ''
UNION ALL SELECT intValidProductCodeId = 389, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '1', strType = ''
UNION ALL SELECT intValidProductCodeId = 390, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '1', strType = ''
UNION ALL SELECT intValidProductCodeId = 391, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '1', strType = ''
UNION ALL SELECT intValidProductCodeId = 392, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '1', strType = ''
UNION ALL SELECT intValidProductCodeId = 393, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '1', strType = ''
UNION ALL SELECT intValidProductCodeId = 394, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '1', strType = ''
UNION ALL SELECT intValidProductCodeId = 395, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '1', strType = ''
UNION ALL SELECT intValidProductCodeId = 396, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '1', strType = ''
UNION ALL SELECT intValidProductCodeId = 397, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '1', strType = ''
UNION ALL SELECT intValidProductCodeId = 398, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '2E', strType = ''
UNION ALL SELECT intValidProductCodeId = 399, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '2E', strType = ''
UNION ALL SELECT intValidProductCodeId = 400, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '2E', strType = ''
UNION ALL SELECT intValidProductCodeId = 401, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '2E', strType = ''
UNION ALL SELECT intValidProductCodeId = 402, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '2E', strType = ''
UNION ALL SELECT intValidProductCodeId = 403, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '2E', strType = ''
UNION ALL SELECT intValidProductCodeId = 404, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '2E', strType = ''
UNION ALL SELECT intValidProductCodeId = 405, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '2E', strType = ''
UNION ALL SELECT intValidProductCodeId = 406, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '2E', strType = ''
UNION ALL SELECT intValidProductCodeId = 407, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '2E', strType = ''
UNION ALL SELECT intValidProductCodeId = 408, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '2E', strType = ''
UNION ALL SELECT intValidProductCodeId = 409, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '2E', strType = ''
UNION ALL SELECT intValidProductCodeId = 410, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '2E', strType = ''
UNION ALL SELECT intValidProductCodeId = 411, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '2E', strType = ''
UNION ALL SELECT intValidProductCodeId = 412, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '2E', strType = ''
UNION ALL SELECT intValidProductCodeId = 413, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '2E', strType = ''
UNION ALL SELECT intValidProductCodeId = 414, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '2E', strType = ''
UNION ALL SELECT intValidProductCodeId = 415, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '2E', strType = ''
UNION ALL SELECT intValidProductCodeId = 416, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '2E', strType = ''
UNION ALL SELECT intValidProductCodeId = 417, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '2K', strType = ''
UNION ALL SELECT intValidProductCodeId = 418, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '2K', strType = ''
UNION ALL SELECT intValidProductCodeId = 419, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '2K', strType = ''
UNION ALL SELECT intValidProductCodeId = 420, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '2K', strType = ''
UNION ALL SELECT intValidProductCodeId = 421, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '2K', strType = ''
UNION ALL SELECT intValidProductCodeId = 422, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '2K', strType = ''
UNION ALL SELECT intValidProductCodeId = 423, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '2K', strType = ''
UNION ALL SELECT intValidProductCodeId = 424, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '2K', strType = ''
UNION ALL SELECT intValidProductCodeId = 425, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '2K', strType = ''
UNION ALL SELECT intValidProductCodeId = 426, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '2K', strType = ''
UNION ALL SELECT intValidProductCodeId = 427, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '2K', strType = ''
UNION ALL SELECT intValidProductCodeId = 428, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '2K', strType = ''
UNION ALL SELECT intValidProductCodeId = 429, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '2K', strType = ''
UNION ALL SELECT intValidProductCodeId = 430, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '2K', strType = ''
UNION ALL SELECT intValidProductCodeId = 431, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '2K', strType = ''
UNION ALL SELECT intValidProductCodeId = 432, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '2K', strType = ''
UNION ALL SELECT intValidProductCodeId = 433, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '2K', strType = ''
UNION ALL SELECT intValidProductCodeId = 434, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '2K', strType = ''
UNION ALL SELECT intValidProductCodeId = 435, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '2K', strType = ''
UNION ALL SELECT intValidProductCodeId = 436, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '3', strType = ''
UNION ALL SELECT intValidProductCodeId = 437, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '3', strType = ''
UNION ALL SELECT intValidProductCodeId = 438, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '3', strType = ''
UNION ALL SELECT intValidProductCodeId = 439, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '3', strType = ''
UNION ALL SELECT intValidProductCodeId = 440, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '3', strType = ''
UNION ALL SELECT intValidProductCodeId = 441, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '3', strType = ''
UNION ALL SELECT intValidProductCodeId = 442, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '3', strType = ''
UNION ALL SELECT intValidProductCodeId = 443, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '3', strType = ''
UNION ALL SELECT intValidProductCodeId = 444, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '3', strType = ''
UNION ALL SELECT intValidProductCodeId = 445, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '3', strType = ''
UNION ALL SELECT intValidProductCodeId = 446, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '3', strType = ''
UNION ALL SELECT intValidProductCodeId = 447, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '3', strType = ''
UNION ALL SELECT intValidProductCodeId = 448, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '3', strType = ''
UNION ALL SELECT intValidProductCodeId = 449, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '3', strType = ''
UNION ALL SELECT intValidProductCodeId = 450, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '3', strType = ''
UNION ALL SELECT intValidProductCodeId = 451, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '3', strType = ''
UNION ALL SELECT intValidProductCodeId = 452, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '3', strType = ''
UNION ALL SELECT intValidProductCodeId = 453, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '3', strType = ''
UNION ALL SELECT intValidProductCodeId = 454, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '3', strType = ''
UNION ALL SELECT intValidProductCodeId = 455, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '5', strType = ''
UNION ALL SELECT intValidProductCodeId = 456, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '5', strType = ''
UNION ALL SELECT intValidProductCodeId = 457, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '5', strType = ''
UNION ALL SELECT intValidProductCodeId = 458, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '5', strType = ''
UNION ALL SELECT intValidProductCodeId = 459, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '5', strType = ''
UNION ALL SELECT intValidProductCodeId = 460, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '5', strType = ''
UNION ALL SELECT intValidProductCodeId = 461, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '5', strType = ''
UNION ALL SELECT intValidProductCodeId = 462, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '5', strType = ''
UNION ALL SELECT intValidProductCodeId = 463, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '5', strType = ''
UNION ALL SELECT intValidProductCodeId = 464, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '5', strType = ''
UNION ALL SELECT intValidProductCodeId = 465, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '5', strType = ''
UNION ALL SELECT intValidProductCodeId = 466, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '5', strType = ''
UNION ALL SELECT intValidProductCodeId = 467, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '5', strType = ''
UNION ALL SELECT intValidProductCodeId = 468, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '5', strType = ''
UNION ALL SELECT intValidProductCodeId = 469, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '5', strType = ''
UNION ALL SELECT intValidProductCodeId = 470, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '5', strType = ''
UNION ALL SELECT intValidProductCodeId = 471, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '5', strType = ''
UNION ALL SELECT intValidProductCodeId = 472, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '5', strType = ''
UNION ALL SELECT intValidProductCodeId = 473, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '5', strType = ''
UNION ALL SELECT intValidProductCodeId = 474, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '6', strType = ''
UNION ALL SELECT intValidProductCodeId = 475, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '6', strType = ''
UNION ALL SELECT intValidProductCodeId = 476, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '6', strType = ''
UNION ALL SELECT intValidProductCodeId = 477, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '6', strType = ''
UNION ALL SELECT intValidProductCodeId = 478, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '6', strType = ''
UNION ALL SELECT intValidProductCodeId = 479, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '6', strType = ''
UNION ALL SELECT intValidProductCodeId = 480, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '6', strType = ''
UNION ALL SELECT intValidProductCodeId = 481, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '6', strType = ''
UNION ALL SELECT intValidProductCodeId = 482, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '6', strType = ''
UNION ALL SELECT intValidProductCodeId = 483, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '6', strType = ''
UNION ALL SELECT intValidProductCodeId = 484, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '6', strType = ''
UNION ALL SELECT intValidProductCodeId = 485, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '6', strType = ''
UNION ALL SELECT intValidProductCodeId = 486, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '6', strType = ''
UNION ALL SELECT intValidProductCodeId = 487, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '6', strType = ''
UNION ALL SELECT intValidProductCodeId = 488, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '6', strType = ''
UNION ALL SELECT intValidProductCodeId = 489, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '6', strType = ''
UNION ALL SELECT intValidProductCodeId = 490, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '6', strType = ''
UNION ALL SELECT intValidProductCodeId = 491, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '6', strType = ''
UNION ALL SELECT intValidProductCodeId = 492, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '6', strType = ''
UNION ALL SELECT intValidProductCodeId = 493, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '6X', strType = ''
UNION ALL SELECT intValidProductCodeId = 494, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '6X', strType = ''
UNION ALL SELECT intValidProductCodeId = 495, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '6X', strType = ''
UNION ALL SELECT intValidProductCodeId = 496, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '6X', strType = ''
UNION ALL SELECT intValidProductCodeId = 497, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '6X', strType = ''
UNION ALL SELECT intValidProductCodeId = 498, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '6X', strType = ''
UNION ALL SELECT intValidProductCodeId = 499, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '6X', strType = ''
UNION ALL SELECT intValidProductCodeId = 500, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '6X', strType = ''
UNION ALL SELECT intValidProductCodeId = 501, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '6X', strType = ''
UNION ALL SELECT intValidProductCodeId = 502, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '6X', strType = ''
UNION ALL SELECT intValidProductCodeId = 503, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '6X', strType = ''
UNION ALL SELECT intValidProductCodeId = 504, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '6X', strType = ''
UNION ALL SELECT intValidProductCodeId = 505, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '6X', strType = ''
UNION ALL SELECT intValidProductCodeId = 506, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '6X', strType = ''
UNION ALL SELECT intValidProductCodeId = 507, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '6X', strType = ''
UNION ALL SELECT intValidProductCodeId = 508, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '6X', strType = ''
UNION ALL SELECT intValidProductCodeId = 509, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '6X', strType = ''
UNION ALL SELECT intValidProductCodeId = 510, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '6X', strType = ''
UNION ALL SELECT intValidProductCodeId = 511, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '6X', strType = ''
UNION ALL SELECT intValidProductCodeId = 512, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = ''
UNION ALL SELECT intValidProductCodeId = 513, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = ''
UNION ALL SELECT intValidProductCodeId = 514, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = ''
UNION ALL SELECT intValidProductCodeId = 515, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = ''
UNION ALL SELECT intValidProductCodeId = 516, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = ''
UNION ALL SELECT intValidProductCodeId = 517, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = ''
UNION ALL SELECT intValidProductCodeId = 518, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = ''
UNION ALL SELECT intValidProductCodeId = 519, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = ''
UNION ALL SELECT intValidProductCodeId = 520, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = ''
UNION ALL SELECT intValidProductCodeId = 521, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = ''
UNION ALL SELECT intValidProductCodeId = 522, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = ''
UNION ALL SELECT intValidProductCodeId = 523, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = ''
UNION ALL SELECT intValidProductCodeId = 524, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = ''
UNION ALL SELECT intValidProductCodeId = 525, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = ''
UNION ALL SELECT intValidProductCodeId = 526, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = ''
UNION ALL SELECT intValidProductCodeId = 527, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = ''
UNION ALL SELECT intValidProductCodeId = 528, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = ''
UNION ALL SELECT intValidProductCodeId = 529, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = ''
UNION ALL SELECT intValidProductCodeId = 530, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = ''
UNION ALL SELECT intValidProductCodeId = 531, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 532, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 533, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 534, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 535, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 536, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 537, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 538, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 539, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 540, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 541, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 542, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 543, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 544, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 545, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 546, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 547, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 548, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 549, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 550, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 551, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 552, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 553, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 554, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 555, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 556, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 557, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 558, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 559, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 560, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 561, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 562, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 563, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 564, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 565, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 566, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 567, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 568, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = ''
UNION ALL SELECT intValidProductCodeId = 569, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '8', strType = ''
UNION ALL SELECT intValidProductCodeId = 570, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '8', strType = ''
UNION ALL SELECT intValidProductCodeId = 571, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '8', strType = ''
UNION ALL SELECT intValidProductCodeId = 572, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '8', strType = ''
UNION ALL SELECT intValidProductCodeId = 573, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '8', strType = ''
UNION ALL SELECT intValidProductCodeId = 574, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '8', strType = ''
UNION ALL SELECT intValidProductCodeId = 575, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '8', strType = ''
UNION ALL SELECT intValidProductCodeId = 576, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '8', strType = ''
UNION ALL SELECT intValidProductCodeId = 577, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '8', strType = ''
UNION ALL SELECT intValidProductCodeId = 578, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '8', strType = ''
UNION ALL SELECT intValidProductCodeId = 579, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '8', strType = ''
UNION ALL SELECT intValidProductCodeId = 580, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '10', strType = ''
UNION ALL SELECT intValidProductCodeId = 581, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '10', strType = ''
UNION ALL SELECT intValidProductCodeId = 582, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '10', strType = ''
UNION ALL SELECT intValidProductCodeId = 583, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '10', strType = ''
UNION ALL SELECT intValidProductCodeId = 584, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '10', strType = ''
UNION ALL SELECT intValidProductCodeId = 585, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '10', strType = ''
UNION ALL SELECT intValidProductCodeId = 586, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '10', strType = ''
UNION ALL SELECT intValidProductCodeId = 587, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '11', strType = ''
UNION ALL SELECT intValidProductCodeId = 588, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '11', strType = ''
UNION ALL SELECT intValidProductCodeId = 589, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '11', strType = ''
UNION ALL SELECT intValidProductCodeId = 590, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '11', strType = ''
UNION ALL SELECT intValidProductCodeId = 591, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '11', strType = ''
UNION ALL SELECT intValidProductCodeId = 592, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '11', strType = ''
UNION ALL SELECT intValidProductCodeId = 593, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '11', strType = ''
UNION ALL SELECT intValidProductCodeId = 594, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '11', strType = ''
UNION ALL SELECT intValidProductCodeId = 595, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '11', strType = ''
UNION ALL SELECT intValidProductCodeId = 596, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '11', strType = ''
UNION ALL SELECT intValidProductCodeId = 597, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '11', strType = ''
UNION ALL SELECT intValidProductCodeId = 598, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '11', strType = ''
UNION ALL SELECT intValidProductCodeId = 599, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '11', strType = ''
UNION ALL SELECT intValidProductCodeId = 600, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '11', strType = ''
UNION ALL SELECT intValidProductCodeId = 601, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '11', strType = ''
UNION ALL SELECT intValidProductCodeId = 602, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '11', strType = ''
UNION ALL SELECT intValidProductCodeId = 603, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '11', strType = ''
UNION ALL SELECT intValidProductCodeId = 604, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '11', strType = ''
UNION ALL SELECT intValidProductCodeId = 605, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '11', strType = ''
UNION ALL SELECT intValidProductCodeId = 606, strProductCode = 'B00', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 607, strProductCode = 'B11', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 608, strProductCode = 'D00', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 609, strProductCode = 'D11', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 610, strProductCode = '226', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 611, strProductCode = '227', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 612, strProductCode = '231', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 613, strProductCode = '232', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 614, strProductCode = '153', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 615, strProductCode = '161', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 616, strProductCode = '167', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 617, strProductCode = '154', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 618, strProductCode = '282', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 619, strProductCode = '283', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 620, strProductCode = '224', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 621, strProductCode = '225', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 622, strProductCode = '285', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 623, strProductCode = 'M00', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 624, strProductCode = 'M11', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 625, strProductCode = '125', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 626, strProductCode = '065', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 627, strProductCode = '061', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 628, strProductCode = 'E00', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 629, strProductCode = 'E11', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 1185, strProductCode = 'E10', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 630, strProductCode = '090', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 631, strProductCode = '248', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 632, strProductCode = '198', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 633, strProductCode = '249', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 634, strProductCode = '052', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 635, strProductCode = '196', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 636, strProductCode = '058', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 637, strProductCode = '265', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 638, strProductCode = '126', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 639, strProductCode = '059', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 640, strProductCode = '075', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 641, strProductCode = '223', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 642, strProductCode = '121', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 643, strProductCode = '199', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 644, strProductCode = '091', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 645, strProductCode = '076', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 646, strProductCode = '150', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 647, strProductCode = '130', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 648, strProductCode = '145', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 649, strProductCode = '146', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 650, strProductCode = '147', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 651, strProductCode = '148', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 652, strProductCode = '073', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 653, strProductCode = '074', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 654, strProductCode = '100', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 655, strProductCode = '101', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 656, strProductCode = '092', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 657, strProductCode = '093', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 658, strProductCode = 'B00', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 659, strProductCode = 'B11', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 660, strProductCode = 'D00', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 661, strProductCode = 'D11', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 662, strProductCode = '226', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 663, strProductCode = '227', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 664, strProductCode = '231', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 665, strProductCode = '232', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 666, strProductCode = '153', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 667, strProductCode = '161', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 668, strProductCode = '167', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 669, strProductCode = '154', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 670, strProductCode = '282', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 671, strProductCode = '283', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 672, strProductCode = '224', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 673, strProductCode = '225', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 674, strProductCode = '285', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 675, strProductCode = 'M00', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 676, strProductCode = 'M11', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 677, strProductCode = '125', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 678, strProductCode = '065', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 679, strProductCode = '061', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 680, strProductCode = 'E00', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 681, strProductCode = 'E11', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 1186, strProductCode = 'E10', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 682, strProductCode = '090', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 683, strProductCode = '248', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 684, strProductCode = '198', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 685, strProductCode = '249', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 686, strProductCode = '052', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 687, strProductCode = '196', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 688, strProductCode = '058', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 689, strProductCode = '265', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 690, strProductCode = '126', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 691, strProductCode = '059', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 692, strProductCode = '075', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 693, strProductCode = '223', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 694, strProductCode = '121', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 695, strProductCode = '199', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 696, strProductCode = '091', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 697, strProductCode = '076', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 698, strProductCode = '150', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 699, strProductCode = '130', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 700, strProductCode = '145', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 701, strProductCode = '146', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 702, strProductCode = '147', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 703, strProductCode = '148', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 704, strProductCode = '073', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 705, strProductCode = '074', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 706, strProductCode = '100', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 707, strProductCode = '101', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 708, strProductCode = '092', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 709, strProductCode = '093', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 710, strProductCode = 'B00', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 711, strProductCode = 'B11', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 712, strProductCode = 'D00', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 713, strProductCode = 'D11', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 714, strProductCode = '226', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 715, strProductCode = '227', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 716, strProductCode = '231', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 717, strProductCode = '232', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 718, strProductCode = '153', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 719, strProductCode = '161', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 720, strProductCode = '167', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 721, strProductCode = '154', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 722, strProductCode = '282', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 723, strProductCode = '283', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 724, strProductCode = '224', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 725, strProductCode = '225', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 726, strProductCode = '285', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel'
UNION ALL SELECT intValidProductCodeId = 727, strProductCode = 'M00', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 728, strProductCode = 'M11', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 729, strProductCode = '125', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 730, strProductCode = '065', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 731, strProductCode = '061', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 732, strProductCode = 'E00', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 733, strProductCode = 'E11', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 1187, strProductCode = 'E10', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline'
UNION ALL SELECT intValidProductCodeId = 734, strProductCode = '090', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 735, strProductCode = '248', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 736, strProductCode = '198', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 737, strProductCode = '249', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 738, strProductCode = '052', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 739, strProductCode = '196', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 740, strProductCode = '058', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 741, strProductCode = '265', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 742, strProductCode = '126', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 743, strProductCode = '059', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 744, strProductCode = '075', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 745, strProductCode = '223', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 746, strProductCode = '121', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 747, strProductCode = '199', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 748, strProductCode = '091', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 749, strProductCode = '076', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 750, strProductCode = '150', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 751, strProductCode = '130', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 752, strProductCode = '145', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 753, strProductCode = '146', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 754, strProductCode = '147', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 755, strProductCode = '148', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 756, strProductCode = '073', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 757, strProductCode = '074', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 758, strProductCode = '100', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 759, strProductCode = '101', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 760, strProductCode = '092', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 761, strProductCode = '093', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products'
UNION ALL SELECT intValidProductCodeId = 762, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 763, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 764, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 765, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 766, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 767, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 768, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 1177, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 769, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 770, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 771, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 772, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 773, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 774, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 775, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 776, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 777, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 778, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 779, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 780, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 781, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 782, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 783, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 784, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 785, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 786, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 787, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 788, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 789, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 790, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 791, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 792, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 793, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 794, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 795, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 796, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 797, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 798, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 799, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 800, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 1178, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 801, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 802, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 803, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 804, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 805, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 806, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 807, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 808, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 809, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 810, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 811, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 812, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 813, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 814, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 815, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 816, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 817, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 818, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 819, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 820, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 821, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 822, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 823, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 824, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 825, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 826, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 827, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 828, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 829, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 830, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 831, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 832, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 1179, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol'
UNION ALL SELECT intValidProductCodeId = 833, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 834, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 835, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 836, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene'
UNION ALL SELECT intValidProductCodeId = 837, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 838, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 839, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 840, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 841, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 842, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 843, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 844, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 845, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 846, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 847, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 848, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 849, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 850, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 851, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 852, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 853, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 854, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 855, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 856, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 857, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products'
UNION ALL SELECT intValidProductCodeId = 858, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = ''
UNION ALL SELECT intValidProductCodeId = 859, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = ''
UNION ALL SELECT intValidProductCodeId = 860, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = ''
UNION ALL SELECT intValidProductCodeId = 861, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = ''
UNION ALL SELECT intValidProductCodeId = 862, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = ''
UNION ALL SELECT intValidProductCodeId = 863, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = ''
UNION ALL SELECT intValidProductCodeId = 864, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = ''
UNION ALL SELECT intValidProductCodeId = 865, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = ''
UNION ALL SELECT intValidProductCodeId = 866, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = ''
UNION ALL SELECT intValidProductCodeId = 867, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = ''
UNION ALL SELECT intValidProductCodeId = 868, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = ''
UNION ALL SELECT intValidProductCodeId = 869, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = ''
UNION ALL SELECT intValidProductCodeId = 870, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = ''
UNION ALL SELECT intValidProductCodeId = 871, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = ''
UNION ALL SELECT intValidProductCodeId = 872, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = ''
UNION ALL SELECT intValidProductCodeId = 873, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = ''
UNION ALL SELECT intValidProductCodeId = 874, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = ''
UNION ALL SELECT intValidProductCodeId = 875, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = ''
UNION ALL SELECT intValidProductCodeId = 876, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = ''
UNION ALL SELECT intValidProductCodeId = 877, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = ''
UNION ALL SELECT intValidProductCodeId = 878, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = ''
UNION ALL SELECT intValidProductCodeId = 879, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = ''
UNION ALL SELECT intValidProductCodeId = 880, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = ''
UNION ALL SELECT intValidProductCodeId = 881, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = ''
UNION ALL SELECT intValidProductCodeId = 882, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = ''
UNION ALL SELECT intValidProductCodeId = 883, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = ''
UNION ALL SELECT intValidProductCodeId = 884, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = ''
UNION ALL SELECT intValidProductCodeId = 885, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = ''
UNION ALL SELECT intValidProductCodeId = 886, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = ''
UNION ALL SELECT intValidProductCodeId = 887, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = ''
UNION ALL SELECT intValidProductCodeId = 888, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = ''
UNION ALL SELECT intValidProductCodeId = 889, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = ''
UNION ALL SELECT intValidProductCodeId = 890, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = ''
UNION ALL SELECT intValidProductCodeId = 891, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = ''
UNION ALL SELECT intValidProductCodeId = 892, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = ''
UNION ALL SELECT intValidProductCodeId = 893, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = ''
UNION ALL SELECT intValidProductCodeId = 894, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = ''
UNION ALL SELECT intValidProductCodeId = 895, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = ''
UNION ALL SELECT intValidProductCodeId = 896, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = ''
UNION ALL SELECT intValidProductCodeId = 897, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = ''
UNION ALL SELECT intValidProductCodeId = 898, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = ''
UNION ALL SELECT intValidProductCodeId = 899, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = ''
UNION ALL SELECT intValidProductCodeId = 900, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = ''
UNION ALL SELECT intValidProductCodeId = 901, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = ''
UNION ALL SELECT intValidProductCodeId = 902, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = ''
UNION ALL SELECT intValidProductCodeId = 903, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = ''
UNION ALL SELECT intValidProductCodeId = 904, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = ''
UNION ALL SELECT intValidProductCodeId = 905, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = ''
UNION ALL SELECT intValidProductCodeId = 906, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = ''
UNION ALL SELECT intValidProductCodeId = 907, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = ''
UNION ALL SELECT intValidProductCodeId = 908, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = ''
UNION ALL SELECT intValidProductCodeId = 909, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = ''
UNION ALL SELECT intValidProductCodeId = 910, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = ''
UNION ALL SELECT intValidProductCodeId = 911, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = ''
UNION ALL SELECT intValidProductCodeId = 912, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = ''
UNION ALL SELECT intValidProductCodeId = 913, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = ''
UNION ALL SELECT intValidProductCodeId = 914, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = ''
UNION ALL SELECT intValidProductCodeId = 915, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 916, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 917, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 918, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 919, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 920, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 921, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 922, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 923, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 924, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 925, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 926, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 927, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 928, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 929, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 930, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 931, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 932, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 933, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 934, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 935, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 936, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 937, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 938, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 939, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 940, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 941, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 942, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 943, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 944, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 945, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 946, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 947, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 948, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 949, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 950, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 951, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 952, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 953, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 954, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 955, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 956, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 957, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 958, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 959, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 960, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 961, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 962, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 963, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 964, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 965, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 966, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 967, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 968, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 969, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 970, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 971, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 972, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 973, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 974, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 975, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 976, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 977, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 978, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 979, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 980, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 981, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 982, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 983, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 984, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 985, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 986, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 987, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 988, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 989, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 990, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = ''
UNION ALL SELECT intValidProductCodeId = 991, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 992, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 993, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 994, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 995, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 996, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 997, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 998, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 999, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 1000, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 1001, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 1002, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 1003, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 1004, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 1005, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 1006, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 1007, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 1008, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 1009, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = ''
UNION ALL SELECT intValidProductCodeId = 1010, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 1011, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 1012, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 1013, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 1014, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 1015, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 1016, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 1017, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 1018, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 1019, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 1020, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 1021, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 1022, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 1023, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 1024, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 1025, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 1026, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 1027, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = ''
UNION ALL SELECT intValidProductCodeId = 1028, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = ''

INSERT INTO @ValidOriginStates(
	intValidOriginStateId
	, strFormCode
	, strScheduleCode
	, strType
	, strState
	, strStatus
)
SELECT intValidOriginStateId = 146, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 147, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 148, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 149, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 150, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 151, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 152, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 153, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 154, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 155, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 156, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 157, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 158, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 159, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 160, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 161, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 162, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 163, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 164, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 165, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 166, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 167, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 168, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 169, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 170, strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 171, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 172, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 173, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 174, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 175, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 176, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidOriginStateId = 177, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 178, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 179, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strState = 'IN', strStatus = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 180, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 181, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 182, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strState = 'IN', strStatus = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 183, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strState = 'IN', strStatus = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 184, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strState = 'IN', strStatus = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 185, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strState = 'IN', strStatus = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 186, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strState = 'IN', strStatus = 'Exclude'

INSERT INTO @ValidDestinationStates(
	intValidDestinationStateId
	, strFormCode
	, strScheduleCode
	, strType
	, strState
	, strStatus
)
SELECT intValidDestinationStateId = 82, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 83, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 84, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 85, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 86, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 87, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 88, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 89, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 90, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 91, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 92, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 93, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 94, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 95, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 96, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 97, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 98, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 99, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 100, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'MI', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 101, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strState = 'MI', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 102, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strState = 'MI', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 103, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'KY', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 104, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strState = 'KY', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 105, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strState = 'KY', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 106, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IL', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 107, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strState = 'IL', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 108, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strState = 'IL', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 109, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'OH', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 110, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strState = 'OH', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 111, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strState = 'OH', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 112, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 113, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 114, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 115, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 116, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strState = 'IL', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 117, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strState = 'KY', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 118, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strState = 'MI', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 119, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strState = 'OH', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 120, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strState = 'IL', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 121, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strState = 'KY', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 122, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strState = 'MI', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 123, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strState = 'OH', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 124, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strState = 'IL', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 125, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strState = 'KY', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 126, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strState = 'MI', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 127, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strState = 'OH', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 128, strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 129, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 130, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 131, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 132, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 133, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 134, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 136, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strState = 'IN', strStatus = 'Exclude'
UNION ALL SELECT intValidDestinationStateId = 137, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strState = 'IN', strStatus = 'Exclude'
UNION ALL SELECT intValidDestinationStateId = 138, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strState = 'IN', strStatus = 'Exclude'

EXEC uspTFUpgradeValidProductCodes @TaxAuthorityCode = @TaxAuthorityCode, @ValidProductCodes = @ValidProductCodes
EXEC uspTFUpgradeValidOriginStates @TaxAuthorityCode = @TaxAuthorityCode, @ValidOriginStates = @ValidOriginStates
EXEC uspTFUpgradeValidDestinationStates @TaxAuthorityCode = @TaxAuthorityCode, @ValidDestinationStates = @ValidDestinationStates


-- Reporting Component - Configuration
/* Generate script for Reporting Component - Configurations. Specify Tax Authority Id to filter out specific Reporting Component - Configurations only.
select 'UNION ALL SELECT intReportTemplateId = ' + CAST(intReportTemplateId AS NVARCHAR(10))
	+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + RC.strFormCode + ''''  END
	+ CASE WHEN RC.strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + RC.strScheduleCode + ''''  END
	+ CASE WHEN RC.strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + RC.strType + '''' END
	+ CASE WHEN strTemplateItemId IS NULL THEN ', strTemplateItemId = NULL' ELSE ', strTemplateItemId = ''' + strTemplateItemId + ''''  END
	+ CASE WHEN strReportSection IS NULL THEN ', strReportSection = NULL' ELSE ', strReportSection = ''' + strReportSection + ''''  END
	+ CASE WHEN intReportItemSequence IS NULL THEN ', intReportItemSequence = NULL' ELSE ', intReportItemSequence = ''' + CAST(intReportItemSequence AS NVARCHAR(10)) + ''''  END
	+ CASE WHEN intTemplateItemNumber IS NULL THEN ', intTemplateItemNumber = NULL' ELSE ', intTemplateItemNumber = ''' + CAST(intTemplateItemNumber AS NVARCHAR(10)) + ''''  END
	+ CASE WHEN strDescription IS NULL THEN ', strDescription = NULL' ELSE ', strDescription = ''' + REPLACE(strDescription, '''', '''''') + ''''  END
	+ CASE WHEN Config.strScheduleCode IS NULL THEN ', strScheduleList = NULL' ELSE ', strScheduleList = ''' + Config.strScheduleCode + ''''  END
	+ CASE WHEN strConfiguration IS NULL THEN ', strConfiguration = NULL' ELSE ', strConfiguration = ''' + strConfiguration + ''''  END
	+ CASE WHEN ysnConfiguration IS NULL THEN ', ysnConfiguration = NULL' ELSE ', ysnConfiguration = ''' + CAST(ysnConfiguration AS NVARCHAR(5)) + ''''  END
	+ CASE WHEN ysnDynamicConfiguration IS NULL THEN ', ysnDynamicConfiguration = NULL' ELSE ', ysnDynamicConfiguration = ''' + CAST(ysnDynamicConfiguration AS NVARCHAR(5)) + ''''  END
	+ CASE WHEN strLastIndexOf IS NULL THEN ', strLastIndexOf = NULL' ELSE ', strLastIndexOf = ''' + strLastIndexOf + ''''  END
	+ CASE WHEN strSegment IS NULL THEN ', strSegment = NULL' ELSE ', strSegment = ''' + strSegment + ''''  END
	+ CASE WHEN intConfigurationSequence IS NULL THEN ', intConfigurationSequence = NULL' ELSE ', intConfigurationSequence = ''' + CAST(intConfigurationSequence AS NVARCHAR(10)) + ''''  END
from tblTFTaxReportTemplate Config
left join tblTFReportingComponent RC ON RC.intReportingComponentId = Config.intReportingComponentId
WHERE RC.intTaxAuthorityId = @TaxAuthorityId
*/
DECLARE @ReportingComponentConfigurations AS TFReportingComponentConfigurations

INSERT INTO @ReportingComponentConfigurations(
	intReportTemplateId
	, strFormCode
	, strScheduleCode
	, strType
	, strTemplateItemId
	, strReportSection
	, intReportItemSequence
	, intTemplateItemNumber
	, strDescription
	, strScheduleList
	, strConfiguration
	, ysnConfiguration
	, ysnDynamicConfiguration
	, strLastIndexOf
	, strSegment
	, intSort
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intReportTemplateId = 2, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-001', strReportSection = 'Section 2:    Calculation of Gasoline Taxes Due', intReportItemSequence = '1', intTemplateItemNumber = '1', strDescription = '1. Total receipts (From Section A, Line 8, Column D on back of return)', strScheduleList = '1A,2,2K,2X,3,4', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 3, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-002', strReportSection = 'Section 2:    Calculation of Gasoline Taxes Due', intReportItemSequence = '2', intTemplateItemNumber = '2', strDescription = '2. Total non-taxable disbursements (From Section B, Line 10, Column D on back of return)', strScheduleList = '11,6D,6X,7,8,10A,10B', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 4, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-003', strReportSection = 'Section 2:    Calculation of Gasoline Taxes Due', intReportItemSequence = '3', intTemplateItemNumber = '3', strDescription = '3. Gallons received, gasoline tax paid (From Section A, Line 1, Column A on back of return)', strScheduleList = '1A', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 5, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-004', strReportSection = 'Section 2:    Calculation of Gasoline Taxes Due', intReportItemSequence = '4', intTemplateItemNumber = '4', strDescription = '4.  Billed taxable gallons (Line 1 minus Line 2 minus Line 3)', strScheduleList = '1,2,3', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 6, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-005', strReportSection = 'Section 2:    Calculation of Gasoline Taxes Due', intReportItemSequence = '5', intTemplateItemNumber = '5', strDescription = '5. Licensed gasoline distributor deduction (Multiply Line 4 by <value>)', strScheduleList = '4', strConfiguration = '0.016', ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '10'
UNION ALL SELECT intReportTemplateId = 7, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-006', strReportSection = 'Section 2:    Calculation of Gasoline Taxes Due', intReportItemSequence = '6', intTemplateItemNumber = '6', strDescription = '6. Billed taxable gallons (Line 4 minus Line 5)', strScheduleList = '4,5', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 8, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-007', strReportSection = 'Section 2:    Calculation of Gasoline Taxes Due', intReportItemSequence = '7', intTemplateItemNumber = '7', strDescription = '7. Gasoline tax due (Multiply Line 6 by $<value>)', strScheduleList = '6', strConfiguration = '0.18', ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '20'
UNION ALL SELECT intReportTemplateId = 9, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-008', strReportSection = 'Section 2:    Calculation of Gasoline Taxes Due', intReportItemSequence = '8', intTemplateItemNumber = '8', strDescription = '8. Adjustments (Schedule E-1 must be attached and is subject to Department approval)', strScheduleList = '0', strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '25'
UNION ALL SELECT intReportTemplateId = 10, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-009', strReportSection = 'Section 2:    Calculation of Gasoline Taxes Due', intReportItemSequence = '9', intTemplateItemNumber = '9', strDescription = '9. Total gasoline tax due (Line 7 plus or minus Line 8)', strScheduleList = '7,8', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 11, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-010', strReportSection = 'Section 3:    Calculation of Oil Inspection Fees Due', intReportItemSequence = '1', intTemplateItemNumber = '10', strDescription = '1. Total receipts (From Section A, Line 9, Coumn D on back of return)', strScheduleList = '1A,2,2K,2X,3,4', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 12, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-011', strReportSection = 'Section 3:    Calculation of Oil Inspection Fees Due', intReportItemSequence = '2', intTemplateItemNumber = '11', strDescription = '2. Total non-taxable disbursements (From Section B, Line 11, Column D on back of return)', strScheduleList = '11,6D,6X,7,8', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 13, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-012', strReportSection = 'Section 3:    Calculation of Oil Inspection Fees Due', intReportItemSequence = '3', intTemplateItemNumber = '12', strDescription = '3. Gallons received, oil inspection fee paid (From Section A, Line 1, Column D on back of return)', strScheduleList = '1A', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 14, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-013', strReportSection = 'Section 3:    Calculation of Oil Inspection Fees Due', intReportItemSequence = '4', intTemplateItemNumber = '13', strDescription = '4. Billed taxable gallons (Line 1 minus Line 2 minus Line 3)', strScheduleList = '10,11,12', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 15, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-014', strReportSection = 'Section 3:    Calculation of Oil Inspection Fees Due', intReportItemSequence = '5', intTemplateItemNumber = '14', strDescription = '5. Oil inspection fees due (Multiply Line 4 by $<value>)', strScheduleList = '13', strConfiguration = '0.01', ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '30'
UNION ALL SELECT intReportTemplateId = 16, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-015', strReportSection = 'Section 3:    Calculation of Oil Inspection Fees Due', intReportItemSequence = '6', intTemplateItemNumber = '15', strDescription = '6. Adjustments (Schedule E-1 must be attached and is subject to Department approval)', strScheduleList = '15', strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '32'
UNION ALL SELECT intReportTemplateId = 17, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-016', strReportSection = 'Section 3:    Calculation of Oil Inspection Fees Due', intReportItemSequence = '7', intTemplateItemNumber = '16', strDescription = '7. Total oil inspection fees due (Line 5 plus or minus Line 6)', strScheduleList = '14,15', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 18, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-017', strReportSection = 'Section 4:    Calculation of Total Amount Due', intReportItemSequence = '1', intTemplateItemNumber = '17', strDescription = '1. Total amount due (Section 2, Line 9 plus Section 3, Line 7)', strScheduleList = '9,16', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 19, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-018', strReportSection = 'Section 4:    Calculation of Total Amount Due', intReportItemSequence = '2', intTemplateItemNumber = '18', strDescription = '2. Penalty (Penalty must be added if report is filed after the due date. 10% of tax due or $5.00, whichever is greater. Five dollars ($5.00) is due on a late report showing no tax due.)', strScheduleList = '18', strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '33'
UNION ALL SELECT intReportTemplateId = 20, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-019', strReportSection = 'Section 4:    Calculation of Total Amount Due', intReportItemSequence = '3', intTemplateItemNumber = '19', strDescription = '3. Interest (Interest must be added if report is filed after the due date. Contact the Department for daily interest rates.)', strScheduleList = '19', strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '34'
UNION ALL SELECT intReportTemplateId = 21, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-020', strReportSection = 'Section 4:    Calculation of Total Amount Due', intReportItemSequence = '4', intTemplateItemNumber = '20', strDescription = '4. Net tax due (Line 1 plus Line 2 plus Line 3)', strScheduleList = '17,18,19', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 22, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-021', strReportSection = 'Section 4:    Calculation of Total Amount Due', intReportItemSequence = '5', intTemplateItemNumber = '21', strDescription = '5. Payment(s)', strScheduleList = '0', strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '35'
UNION ALL SELECT intReportTemplateId = 23, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-022', strReportSection = 'Section 4:    Calculation of Total Amount Due', intReportItemSequence = '6', intTemplateItemNumber = '22', strDescription = '6. Balance due (Line 4 minus Line 5)', strScheduleList = '20,21', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 24, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-023', strReportSection = 'Section 4:    Calculation of Total Amount Due', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = '7. Gallons of gasoline sold to taxable marina', strScheduleList = '0', strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '36'
UNION ALL SELECT intReportTemplateId = 42, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-024', strReportSection = 'Section B: Disbursement', intReportItemSequence = '9', intTemplateItemNumber = '18', strDescription = '9. Miscelleaneous deduction - theft/loss', strScheduleList = 'E-1', strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Details', intConfigurationSequence = '39'
UNION ALL SELECT intReportTemplateId = 43, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Summary-025', strReportSection = 'Section B: Disbursement', intReportItemSequence = '10', intTemplateItemNumber = '19', strDescription = '9a. Miscellaneous deduction - off road, other', strScheduleList = 'E-1', strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Details', intConfigurationSequence = '40'
UNION ALL SELECT intReportTemplateId = 146, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-FilingType-001', strReportSection = '1', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'Filing Type', strScheduleList = '', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Filing Type', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 147, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Detail-001', strReportSection = 'Section A: Receipts', intReportItemSequence = '1', intTemplateItemNumber = '1', strDescription = '1. Gallons received, gasoline tax or inspection fee paid', strScheduleList = '1A', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 148, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Detail-002', strReportSection = 'Section A: Receipts', intReportItemSequence = '2', intTemplateItemNumber = '2', strDescription = '2. Gallons received from licensed distributors or oil inspection distributors, tax unpaid', strScheduleList = '2', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 149, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Detail-003', strReportSection = 'Section A: Receipts', intReportItemSequence = '3', intTemplateItemNumber = '3', strDescription = '3. Gallons of non-taxable fuel received and sold or used for a taxable purpose', strScheduleList = '2K', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 150, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Detail-005', strReportSection = 'Section A: Receipts', intReportItemSequence = '4', intTemplateItemNumber = '4', strDescription = '4. Gallons received from licensed distributors on exchange agreements, tax unpaid', strScheduleList = '2X', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 151, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Detail-006', strReportSection = 'Section A: Receipts', intReportItemSequence = '5', intTemplateItemNumber = '5', strDescription = '5. Gallons imported directly to customer', strScheduleList = '3', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 152, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Detail-007', strReportSection = 'Section A: Receipts', intReportItemSequence = '6', intTemplateItemNumber = '6', strDescription = '6. Gallons imported into own storage', strScheduleList = '4', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 153, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Detail-008', strReportSection = 'Section A: Receipts', intReportItemSequence = '7', intTemplateItemNumber = '7', strDescription = '7. Diversions into Indiana', strScheduleList = '11', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 154, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Detail-009', strReportSection = 'Section A: Receipts', intReportItemSequence = '8', intTemplateItemNumber = '8', strDescription = '8. Total receipts - add Lines 1-7, carry total (Column D) to Section 2, Line 1 on front', strScheduleList = '1A,2,2K,2X,3,4', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 155, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Detail-010', strReportSection = 'Section A: Receipts', intReportItemSequence = '9', intTemplateItemNumber = '9', strDescription = '9. Total Receipts - add Lines 1-7, carry total (Column D) to Section 3, Line 1 on front', strScheduleList = '1A,2,2K,2X,3,4', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 156, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Detail-011', strReportSection = 'Section B: Disbursement', intReportItemSequence = '1', intTemplateItemNumber = '10', strDescription = '1. Gallons delivered, tax collected', strScheduleList = '5', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 157, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Detail-012', strReportSection = 'Section B: Disbursement', intReportItemSequence = '2', intTemplateItemNumber = '11', strDescription = '2. Diversion out of Indiana', strScheduleList = '11', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 158, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Detail-013', strReportSection = 'Section B: Disbursement', intReportItemSequence = '3', intTemplateItemNumber = '12', strDescription = '3. Gallons sold to licensed distributors, tax not collected', strScheduleList = '6D', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 159, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Detail-014', strReportSection = 'Section B: Disbursement', intReportItemSequence = '4', intTemplateItemNumber = '13', strDescription = '4. Gallons disbursed on exchange', strScheduleList = '6X', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 160, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Detail-015', strReportSection = 'Section B: Disbursement', intReportItemSequence = '5', intTemplateItemNumber = '14', strDescription = '5. Gallons exported (must be filed in duplicate)', strScheduleList = '7', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 161, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Detail-016', strReportSection = 'Section B: Disbursement', intReportItemSequence = '6', intTemplateItemNumber = '15', strDescription = '6. Gallons delivered to U.S. Government - tax exempt', strScheduleList = '8', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 162, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Detail-017', strReportSection = 'Section B: Disbursement', intReportItemSequence = '7', intTemplateItemNumber = '16', strDescription = '7 Gallons delivered to licensed marina fuel dealers', strScheduleList = '10A', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 163, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Detail-018', strReportSection = 'Section B: Disbursement', intReportItemSequence = '8', intTemplateItemNumber = '17', strDescription = '8. Gallons delivered to licensed aviation fuel dealers', strScheduleList = '10B', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 164, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Detail-019', strReportSection = 'Section B: Disbursement', intReportItemSequence = '11', intTemplateItemNumber = '20', strDescription = '10. Total non-taxable disbursements - add Lines 2-9a, carry total to Section 2, line 2 on front.', strScheduleList = '11,6D,6X,7,8,10A,10B', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 165, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Detail-020', strReportSection = 'Section B: Disbursement', intReportItemSequence = '12', intTemplateItemNumber = '21', strDescription = '11. Total non-taxable disbursements - add Lines 2-6, carry total to Section 3, line 2 on front', strScheduleList = '11,6D,6X,7,8', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 166, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-LicenseNumber', strReportSection = 'HEADER', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'License Number', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'HEADER', intConfigurationSequence = '5'
UNION ALL SELECT intReportTemplateId = 167, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Header-01', strReportSection = 'HEADER', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'FilingType - Gasoline', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'HEADER', intConfigurationSequence = '6'
UNION ALL SELECT intReportTemplateId = 168, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Header-02', strReportSection = 'HEADER', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'FilingType - Oil Inspection', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'HEADER', intConfigurationSequence = '7'
UNION ALL SELECT intReportTemplateId = 169, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-Header-03', strReportSection = 'HEADER', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'FilingType - Gasohol Blender', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'HEADER', intConfigurationSequence = '8'
UNION ALL SELECT intReportTemplateId = 170, strFormCode = 'MF-360', strScheduleCode = '', strType = '', strTemplateItemId = 'MF-360-LicenseHolderName', strReportSection = 'HEADER', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'Name of License Holder', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'HEADER', intConfigurationSequence = '1'
UNION ALL SELECT intReportTemplateId = 197, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasoline', strTemplateItemId = 'GT-103-2DGasoline', strReportSection = 'Schedule', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'Reporting Period GUT Rate', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '0'
UNION ALL SELECT intReportTemplateId = 198, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', strTemplateItemId = 'GT-103-2DGasohol', strReportSection = 'Schedule', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'Reporting Period GUT Rate', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '0'
UNION ALL SELECT intReportTemplateId = 182, strFormCode = 'GT-103', strScheduleCode = '', strType = '', strTemplateItemId = 'GT-103-Detail-002', strReportSection = 'Receipts - Schedule 1', intReportItemSequence = '1', intTemplateItemNumber = '1', strDescription = 'Gasoline', strScheduleList = '1R', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 183, strFormCode = 'GT-103', strScheduleCode = '', strType = '', strTemplateItemId = 'GT-103-Detail-003', strReportSection = 'Receipts - Schedule 1', intReportItemSequence = '2', intTemplateItemNumber = '2', strDescription = 'Gasohol', strScheduleList = '1R', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 184, strFormCode = 'GT-103', strScheduleCode = '', strType = '', strTemplateItemId = 'GT-103-Detail-004', strReportSection = 'Receipts - Schedule 1', intReportItemSequence = '3', intTemplateItemNumber = '3', strDescription = 'Total Gallons of Fuel Purchased', strScheduleList = '1R', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 185, strFormCode = 'GT-103', strScheduleCode = '', strType = '', strTemplateItemId = 'GT-103-Detail-005', strReportSection = 'Disbursements - Schedule 2', intReportItemSequence = '1', intTemplateItemNumber = '4', strDescription = 'Gasoline', strScheduleList = '2D', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 186, strFormCode = 'GT-103', strScheduleCode = '', strType = '', strTemplateItemId = 'GT-103-Detail-006', strReportSection = 'Disbursements - Schedule 2', intReportItemSequence = '2', intTemplateItemNumber = '5', strDescription = 'Gasohol', strScheduleList = '2D', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 187, strFormCode = 'GT-103', strScheduleCode = '', strType = '', strTemplateItemId = 'GT-103-Detail-007', strReportSection = 'Disbursements - Schedule 2', intReportItemSequence = '3', intTemplateItemNumber = '6', strDescription = 'Total Gallons of Fuel Sold', strScheduleList = '2D', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 188, strFormCode = 'GT-103', strScheduleCode = '', strType = '', strTemplateItemId = 'GT-103-TID', strReportSection = 'HEADER', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'Taxpayer Identification Number', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'HEADER', intConfigurationSequence = '5'
UNION ALL SELECT intReportTemplateId = 189, strFormCode = 'GT-103', strScheduleCode = '', strType = '', strTemplateItemId = 'GT-103-TaxPayerName', strReportSection = 'HEADER', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'Tax Payer Name', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'HEADER', intConfigurationSequence = '1'
UNION ALL SELECT intReportTemplateId = 99, strFormCode = 'GT-103', strScheduleCode = '', strType = '', strTemplateItemId = 'GT-103-Summary-001', strReportSection = 'Gasoline Use Tax', intReportItemSequence = '1', intTemplateItemNumber = '1', strDescription = '1. Total Gallons Sold for Period', strScheduleList = '2D,1R', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 100, strFormCode = 'GT-103', strScheduleCode = '', strType = '', strTemplateItemId = 'GT-103-Summary-002', strReportSection = 'Gasoline Use Tax', intReportItemSequence = '2', intTemplateItemNumber = '2', strDescription = '2. Total Exempt Gallons Sold for Period', strScheduleList = '2D', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 101, strFormCode = 'GT-103', strScheduleCode = '', strType = '', strTemplateItemId = 'GT-103-Summary-003', strReportSection = 'Gasoline Use Tax', intReportItemSequence = '3', intTemplateItemNumber = '3', strDescription = '3. Total Taxable Gallons Sold (Line 1 minus Line 2)', strScheduleList = '1,2', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 102, strFormCode = 'GT-103', strScheduleCode = '', strType = '', strTemplateItemId = 'GT-103-Summary-004', strReportSection = 'Gasoline Use Tax', intReportItemSequence = '4', intTemplateItemNumber = '4', strDescription = '4. Gasoline Use Tax Due. (Line 3 multiplied by the current rate. See Departmental Notice #2', strScheduleList = '3', strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '9'
UNION ALL SELECT intReportTemplateId = 103, strFormCode = 'GT-103', strScheduleCode = '', strType = '', strTemplateItemId = 'GT-103-Summary-005', strReportSection = 'Gasoline Use Tax', intReportItemSequence = '5', intTemplateItemNumber = '5', strDescription = '5. Collection Allowance. Do not calculate this allowance if your return and payment are late. Collection allowance rate is 1%', strScheduleList = '4', strConfiguration = '0.73', ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '10'
UNION ALL SELECT intReportTemplateId = 104, strFormCode = 'GT-103', strScheduleCode = '', strType = '', strTemplateItemId = 'GT-103-Summary-006', strReportSection = 'Gasoline Use Tax', intReportItemSequence = '6', intTemplateItemNumber = '6', strDescription = '6. Net Gasoline Use Tax Due. Subtotal of use tax and collection allowance. (Line 4 minus Line 5)', strScheduleList = '4,5', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 105, strFormCode = 'GT-103', strScheduleCode = '', strType = '', strTemplateItemId = 'GT-103-Summary-007', strReportSection = 'Gasoline Use Tax', intReportItemSequence = '7', intTemplateItemNumber = '7', strDescription = '7. Penalty Due. If late, the penalty is 10% of the tax due on Line 6 or $5, whichever is greater.', strScheduleList = '6', strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '20'
UNION ALL SELECT intReportTemplateId = 106, strFormCode = 'GT-103', strScheduleCode = '', strType = '', strTemplateItemId = 'GT-103-Summary-008', strReportSection = 'Gasoline Use Tax', intReportItemSequence = '8', intTemplateItemNumber = '8', strDescription = '8. Interest Due. If late, multiply Line 6 by the interest rate (see Departmental Notice #)', strScheduleList = '6', strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '30'
UNION ALL SELECT intReportTemplateId = 107, strFormCode = 'GT-103', strScheduleCode = '', strType = '', strTemplateItemId = 'GT-103-Summary-009', strReportSection = 'Gasoline Use Tax', intReportItemSequence = '9', intTemplateItemNumber = '9', strDescription = '9. Electronic Funds Transfer Credit', strScheduleList = '0', strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '40'
UNION ALL SELECT intReportTemplateId = 108, strFormCode = 'GT-103', strScheduleCode = '', strType = '', strTemplateItemId = 'GT-103-Summary-010', strReportSection = 'Gasoline Use Tax', intReportItemSequence = '10', intTemplateItemNumber = '10', strDescription = '10. Adjustments. If negative entry, use a negative sign. (You must provide an explanation and supporting documentation to the Fuel Tax section.)', strScheduleList = '0', strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '50'
UNION ALL SELECT intReportTemplateId = 109, strFormCode = 'GT-103', strScheduleCode = '', strType = '', strTemplateItemId = 'GT-103-Summary-011', strReportSection = 'Gasoline Use Tax', intReportItemSequence = '11', intTemplateItemNumber = '11', strDescription = '11. Total Amount Due. (Add Lines 6 through 8, subtract Line 9, add Line 10).', strScheduleList = '6,7,8', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 52, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-001', strReportSection = 'Section 2: Computation of Tax', intReportItemSequence = '1', intTemplateItemNumber = '1', strDescription = '1. Total Receipts (From Section A, Line 5 on back of return)', strScheduleList = '1,2E,2K,3', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 53, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-002', strReportSection = 'Section 2: Computation of Tax', intReportItemSequence = '2', intTemplateItemNumber = '2', strDescription = '2. Total Non-Taxable Disbursements (From Section B, Line 11 on back of return)', strScheduleList = '6,6X,7,7A,7B,8,10', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 54, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-003', strReportSection = 'Section 2: Computation of Tax', intReportItemSequence = '3', intTemplateItemNumber = '3', strDescription = '3. Taxable Gallons Sold or Used (From Section B, Line 3, on back of return)', strScheduleList = '8,9', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 55, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-004', strReportSection = 'Section 2: Computation of Tax', intReportItemSequence = '4', intTemplateItemNumber = '4', strDescription = '4.  Gallons Received Tax Paid (From Section A, Line 1, on back of return)', strScheduleList = '1', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 56, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-005', strReportSection = 'Section 2: Computation of Tax', intReportItemSequence = '5', intTemplateItemNumber = '5', strDescription = '5. Billed Taxable Gallons (Line 3 minus Line 4)', strScheduleList = '3,4', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 57, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-006', strReportSection = 'Section 2: Computation of Tax', intReportItemSequence = '6', intTemplateItemNumber = '6', strDescription = '6. Tax Due (Multiply Line 5 by $<value>)', strScheduleList = '5', strConfiguration = '0.16', ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '50'
UNION ALL SELECT intReportTemplateId = 58, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-007', strReportSection = 'Section 2: Computation of Tax', intReportItemSequence = '7', intTemplateItemNumber = '7', strDescription = '7. Amount of Tax Uncollectible from Eligible Purchasers - Complete Schedule 10E', strScheduleList = '0', strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '60'
UNION ALL SELECT intReportTemplateId = 59, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-008', strReportSection = 'Section 2: Computation of Tax', intReportItemSequence = '8', intTemplateItemNumber = '8', strDescription = '8. Adjusted Tax Due (Line 6 minus Line 7)', strScheduleList = '6,7', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 60, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-009', strReportSection = 'Section 2: Computation of Tax', intReportItemSequence = '9', intTemplateItemNumber = '9', strDescription = '9. Collection Allowance (Multiply Line 8 by <value>). If return filed or tax paid after due date enter zero (0)', strScheduleList = '8', strConfiguration = '0.016', ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = 'by', strSegment = 'Summary', intConfigurationSequence = '70'
UNION ALL SELECT intReportTemplateId = 61, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-010', strReportSection = 'Section 2: Computation of Tax', intReportItemSequence = '10', intTemplateItemNumber = '10', strDescription = '10. Adjustment - Complete Schedule E-1 (Dollar amount only)', strScheduleList = '0', strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '80'
UNION ALL SELECT intReportTemplateId = 62, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-011', strReportSection = 'Section 2: Computation of Tax', intReportItemSequence = '11', intTemplateItemNumber = '11', strDescription = '11. Total special fuel tax due (Line 8 minus Line 9 plus or minus Line 10)', strScheduleList = '8,9,10', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 63, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-012', strReportSection = 'Section 3:    Calculation of Oil Inspection Fees Due', intReportItemSequence = '1', intTemplateItemNumber = '12', strDescription = '1. Total billed gallons (From Section 2, Line 5)', strScheduleList = '3,4', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 64, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-013', strReportSection = 'Section 3:    Calculation of Oil Inspection Fees Due', intReportItemSequence = '2', intTemplateItemNumber = '13', strDescription = '2. Oil inspection fees due (Multiply Line 1 by $<value>)', strScheduleList = '12', strConfiguration = '0.01', ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '90'
UNION ALL SELECT intReportTemplateId = 65, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-014', strReportSection = 'Section 3:    Calculation of Oil Inspection Fees Due', intReportItemSequence = '3', intTemplateItemNumber = '14', strDescription = '3. Adjustments (Schedule E-1 must be attached and is subject to Department approval)', strScheduleList = '0', strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '100'
UNION ALL SELECT intReportTemplateId = 66, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-015', strReportSection = 'Section 3:    Calculation of Oil Inspection Fees Due', intReportItemSequence = '4', intTemplateItemNumber = '15', strDescription = '4. Total oil inspection fees due (Line 2 plus or minus Line 3)', strScheduleList = '13,14', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 67, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-016', strReportSection = 'Section 4: Calculation of Total Amount Due', intReportItemSequence = '1', intTemplateItemNumber = '16', strDescription = '1. Total amount due (Section 2, Line 11 plus Section 3, Line 4)', strScheduleList = '11,15', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 68, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-017', strReportSection = 'Section 4: Calculation of Total Amount Due', intReportItemSequence = '2', intTemplateItemNumber = '17', strDescription = '2. Penalty (Penalty must be added if report is filed after the due date. 10% of tax due or $5.00, whichever is greater. Five dollars ($5.00) is due on a late report showing no tax due.)', strScheduleList = '0', strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '110'
UNION ALL SELECT intReportTemplateId = 69, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-018', strReportSection = 'Section 4: Calculation of Total Amount Due', intReportItemSequence = '3', intTemplateItemNumber = '18', strDescription = '3. Interest (Interest must be added if report is filed after the due date. Contact the Department for daily interest rates.)', strScheduleList = '0', strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '120'
UNION ALL SELECT intReportTemplateId = 70, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-019', strReportSection = 'Section 4: Calculation of Total Amount Due', intReportItemSequence = '4', intTemplateItemNumber = '19', strDescription = '4. Net tax due (Line 1 plus Line 2 plus Line 3)', strScheduleList = '16,17,18', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 71, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-020', strReportSection = 'Section 4: Calculation of Total Amount Due', intReportItemSequence = '5', intTemplateItemNumber = '20', strDescription = '5. Payment(s)', strScheduleList = '0', strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '130'
UNION ALL SELECT intReportTemplateId = 72, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-021', strReportSection = 'Section 4: Calculation of Total Amount Due', intReportItemSequence = '6', intTemplateItemNumber = '21', strDescription = '6. Balance due (Line 4 minus Line 5)', strScheduleList = '19,20', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 74, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-023', strReportSection = 'Section A: Receipts', intReportItemSequence = '2', intTemplateItemNumber = '2', strDescription = '1. Gallons Received Tax Paid (Carry forward to Section 2, Line 4 on front of return)', strScheduleList = '1', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 75, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-024', strReportSection = 'Section A: Receipts', intReportItemSequence = '3', intTemplateItemNumber = '3', strDescription = '2. Gallons Received for Export (To be completed only by licensed exporters)', strScheduleList = '2E', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 76, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-025', strReportSection = 'Section A: Receipts', intReportItemSequence = '4', intTemplateItemNumber = '4', strDescription = '3. Gallons of Nontaxable Fuel Received and Sold or Used For a Taxable Purpose', strScheduleList = '2K', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 77, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-026', strReportSection = 'Section A: Receipts', intReportItemSequence = '5', intTemplateItemNumber = '5', strDescription = '4. Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid', strScheduleList = '3', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 78, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-027', strReportSection = 'Section A: Receipts', intReportItemSequence = '6', intTemplateItemNumber = '6', strDescription = '5. Total Receipts (Add Lines 1 through 4, carry forward to Section 2, Line 1 on', strScheduleList = '1,2E,2K,3', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 80, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-029', strReportSection = 'Section B: Disbursement', intReportItemSequence = '2', intTemplateItemNumber = '8', strDescription = '1. Gallons Delivered Tax Collected and Gallons Blended or Dyed Fuel Used', strScheduleList = '5', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 81, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-030', strReportSection = 'Section B: Disbursement', intReportItemSequence = '3', intTemplateItemNumber = '9', strDescription = '2. Diversions (Special fuel only)', strScheduleList = '11', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 82, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-031', strReportSection = 'Section B: Disbursement', intReportItemSequence = '4', intTemplateItemNumber = '10', strDescription = '3. Taxable Gallons Sold or Used (Carry forward to Section 2, Line 3 on front of return)', strScheduleList = '8,9', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 83, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-032', strReportSection = 'Section B: Disbursement', intReportItemSequence = '5', intTemplateItemNumber = '11', strDescription = '4. Gallons Delivered Via Rail, Pipeline, or Vessel to Licensed Suppliers, Tax Not Collected', strScheduleList = '6', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 84, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-033', strReportSection = 'Section B: Disbursement', intReportItemSequence = '6', intTemplateItemNumber = '12', strDescription = '5. Gallons Disbursed on Exchange for Other Suppliers or Permissive Suppliers', strScheduleList = '6X', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 85, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-034', strReportSection = 'Section B: Disbursement', intReportItemSequence = '7', intTemplateItemNumber = '13', strDescription = '6. Gallons Exported by License Holder', strScheduleList = '7', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 86, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-035', strReportSection = 'Section B: Disbursement', intReportItemSequence = '8', intTemplateItemNumber = '14', strDescription = '7. Gallons Sold to Unlicensed Exporters for Export', strScheduleList = '7A', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 87, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-036', strReportSection = 'Section B: Disbursement', intReportItemSequence = '9', intTemplateItemNumber = '15', strDescription = '8. Gallons Sold to Licensed Exporters for Export', strScheduleList = '7B', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 88, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-037', strReportSection = 'Section B: Disbursement', intReportItemSequence = '10', intTemplateItemNumber = '16', strDescription = '9. Gallons of Undyed Fuel Sold to the U.S. Government - Tax Exempt', strScheduleList = '8', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 89, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-038', strReportSection = 'Section B: Disbursement', intReportItemSequence = '11', intTemplateItemNumber = '17', strDescription = '10. Gallons Sold of Tax Exempt Dyed Fuel', strScheduleList = '10', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 90, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-039', strReportSection = 'Section B: Disbursement', intReportItemSequence = '12', intTemplateItemNumber = '18', strDescription = '11. Total Non-Taxable Disbursements (Add Lines 4 through 10; carry forward to Section 2, Line 2 on front of return)', strScheduleList = '6,6X,7,7A,7B,8,10', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 97, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'LicenseHolderName', strReportSection = 'HEADER', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'Name of License Holder', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'HEADER', intConfigurationSequence = '1'
UNION ALL SELECT intReportTemplateId = 171, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-FilingType-001', strReportSection = '1', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'Filing Type', strScheduleList = '', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Filing Type', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 172, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-022', strReportSection = 'Section A: Receipts', intReportItemSequence = '1', intTemplateItemNumber = '1', strDescription = 'Section A:    Receipts', strScheduleList = '0', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 173, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-028', strReportSection = 'Section B: Disbursement', intReportItemSequence = '1', intTemplateItemNumber = '7', strDescription = 'Section B:    Disbursements', strScheduleList = '0', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 174, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Header-01', strReportSection = 'HEADER', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'Supplier', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'HEADER', intConfigurationSequence = '3'
UNION ALL SELECT intReportTemplateId = 175, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Header-02', strReportSection = 'HEADER', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'Permissive Supplier', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'HEADER', intConfigurationSequence = '4'
UNION ALL SELECT intReportTemplateId = 176, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Header-03', strReportSection = 'HEADER', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'Importer', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'HEADER', intConfigurationSequence = '5'
UNION ALL SELECT intReportTemplateId = 177, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Header-04', strReportSection = 'HEADER', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'Exporter', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'HEADER', intConfigurationSequence = '6'
UNION ALL SELECT intReportTemplateId = 178, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Header-05', strReportSection = 'HEADER', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'Blender', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'HEADER', intConfigurationSequence = '7'
UNION ALL SELECT intReportTemplateId = 179, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Header-06', strReportSection = 'HEADER', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'Dyed Fuel User', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'HEADER', intConfigurationSequence = '8'
UNION ALL SELECT intReportTemplateId = 180, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-LicenseHolderName', strReportSection = 'HEADER', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'Name of License Holder', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'HEADER', intConfigurationSequence = '1'
UNION ALL SELECT intReportTemplateId = 181, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-LicenseNumber', strReportSection = 'HEADER', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'License Number', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'HEADER', intConfigurationSequence = '2'
UNION ALL SELECT intReportTemplateId = 190, strFormCode = 'SF-401', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-401-FilingType-001', strReportSection = '1', intReportItemSequence = '0', intTemplateItemNumber = '0', strDescription = 'Filing Type', strScheduleList = '', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Filing Type', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 191, strFormCode = 'SF-401', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-401-Summary-001', strReportSection = '', intReportItemSequence = '1', intTemplateItemNumber = '1', strDescription = '1. Total gallons of fuel loaded from an Indiana terminal or bulk plant and delivered to another state.', strScheduleList = '1A', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 192, strFormCode = 'SF-401', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-401-Summary-002', strReportSection = '', intReportItemSequence = '2', intTemplateItemNumber = '2', strDescription = '2. Total gallons of fuel loaded from an out-of-state terminal or bulk plant and delivered into Indiana.', strScheduleList = '2A', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 193, strFormCode = 'SF-401', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-401-Summary-003', strReportSection = '', intReportItemSequence = '3', intTemplateItemNumber = '3', strDescription = '3. Total gallons of fuel loaded from an Indiana terminal or bulk plant and delivered within Indiana.', strScheduleList = '3A', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 194, strFormCode = 'SF-401', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-401-Summary-004', strReportSection = '', intReportItemSequence = '4', intTemplateItemNumber = '4', strDescription = '4. Total gallons of fuel transported (Add lines 1, 2, and 3).', strScheduleList = '1A,2A,3A', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 195, strFormCode = 'SF-401', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-401-LicenseNumber', strReportSection = '', intReportItemSequence = '5', intTemplateItemNumber = '5', strDescription = 'License Number', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '10'
UNION ALL SELECT intReportTemplateId = 196, strFormCode = 'SF-401', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-401-MotorCarrier', strReportSection = '', intReportItemSequence = '6', intTemplateItemNumber = '6', strDescription = 'Motor Carrier / IFTA Number', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = '20'
UNION ALL SELECT intReportTemplateId = 118, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA01', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '0', strDescription = 'ISA01 - Authorization Information Qualifier', strScheduleList = NULL, strConfiguration = '03', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '42'
UNION ALL SELECT intReportTemplateId = 119, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA02', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '0', strDescription = 'ISA02 - Authorization Information', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '46'
UNION ALL SELECT intReportTemplateId = 120, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA03', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '0', strDescription = 'ISA03 - Security Information Qualifier', strScheduleList = NULL, strConfiguration = '01', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '48'
UNION ALL SELECT intReportTemplateId = 121, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA04', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '0', strDescription = 'ISA04 - Security Information', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '50'
UNION ALL SELECT intReportTemplateId = 122, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA05', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ISA07 - Interchange ID Qualifier', strScheduleList = NULL, strConfiguration = '32', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '55'
UNION ALL SELECT intReportTemplateId = 123, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA06', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ISA06 - Interchange Sender ID (including 6 trailing spaces)', strScheduleList = NULL, strConfiguration = '123456789      ', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '60'
UNION ALL SELECT intReportTemplateId = 124, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA07', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ISA07 - Interchange ID Qualifier', strScheduleList = NULL, strConfiguration = '01', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '65'
UNION ALL SELECT intReportTemplateId = 125, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA08', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ISA08 - Interchange Receiver ID (including 6 trailing spaces)', strScheduleList = NULL, strConfiguration = '824799308      ', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '70'
UNION ALL SELECT intReportTemplateId = 126, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA11', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ISA11 - Repetition Separator', strScheduleList = NULL, strConfiguration = '|', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '75'
UNION ALL SELECT intReportTemplateId = 127, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA12', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ISA12 - Interchange Control Version Number', strScheduleList = NULL, strConfiguration = '00403', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '80'
UNION ALL SELECT intReportTemplateId = 128, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA13', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ISA13 - Interchange Control Number (for next transmission)', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '85'
UNION ALL SELECT intReportTemplateId = 129, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA14', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ISA14 - Acknowledgement Requested', strScheduleList = NULL, strConfiguration = '0', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '90'
UNION ALL SELECT intReportTemplateId = 130, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA15', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ISA15 - Usage Indicator', strScheduleList = NULL, strConfiguration = 'T', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '95'
UNION ALL SELECT intReportTemplateId = 131, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ISA16', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ISA16 - Component Sub-element Separator', strScheduleList = NULL, strConfiguration = '^', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '100'
UNION ALL SELECT intReportTemplateId = 132, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-GS01', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'GS01 - Functional Identifier Code', strScheduleList = NULL, strConfiguration = 'TF', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '105'
UNION ALL SELECT intReportTemplateId = 133, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-GS02', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'GS02 - Application Sender''s Code (no trailing space)', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '110'
UNION ALL SELECT intReportTemplateId = 134, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-GS03', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'GS03 - Receiver''s Code', strScheduleList = NULL, strConfiguration = '824799308050', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '115'
UNION ALL SELECT intReportTemplateId = 135, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-GS06', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'GS06 - Group Control Number (for next transmission)', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '120'
UNION ALL SELECT intReportTemplateId = 136, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-GS07', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'GS07 - Responsible Agency Code', strScheduleList = NULL, strConfiguration = 'X', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '125'
UNION ALL SELECT intReportTemplateId = 137, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-GS08', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'GS08 - Version/Release/Industry ID Code', strScheduleList = NULL, strConfiguration = '004030', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '130'
UNION ALL SELECT intReportTemplateId = 138, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ST01', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ST01 - Transaction Set Code', strScheduleList = NULL, strConfiguration = '813', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '135'
UNION ALL SELECT intReportTemplateId = 139, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-ST02', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'ST02 - Transaction Set Control Number (for next transmission)', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '137'
UNION ALL SELECT intReportTemplateId = 140, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-BTI13', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'BTI13 - Transaction Set Purpose Code', strScheduleList = NULL, strConfiguration = '00', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '140'
UNION ALL SELECT intReportTemplateId = 141, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-BTI14', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'BTI14 - Transaction Type Code', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '145'
UNION ALL SELECT intReportTemplateId = 142, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-FilePath', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'EDI File Path', strScheduleList = NULL, strConfiguration = 'C:\dir', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '155'
UNION ALL SELECT intReportTemplateId = 143, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-FileName1st', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'EDI File Name - 1st part (TST or PRD)', strScheduleList = NULL, strConfiguration = 'T', ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Summary', intConfigurationSequence = '160'
UNION ALL SELECT intReportTemplateId = 144, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-FileName2nd', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'EDI File Name - 2nd part (Tax Payer Code)', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '165'
UNION ALL SELECT intReportTemplateId = 145, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', strTemplateItemId = 'EDI-FileName3rd', strReportSection = 'EDI', intReportItemSequence = '7', intTemplateItemNumber = '23', strDescription = 'EDI File Name - 3rd part (Next Sequence Number)', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '170'

EXEC uspTFUpgradeReportingComponentConfigurations @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponentConfigurations = @ReportingComponentConfigurations


-- Reporting Component - Output Designer
/* Generate script for Reporting Component - Output Designer. Specify Tax Authority Id to filter out specific Reporting Component - Output Designer only.
select 'UNION ALL SELECT intScheduleColumnId = ' + CAST(intReportingComponentFieldId AS NVARCHAR(10))
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN strColumn IS NULL THEN ', strColumn = NULL' ELSE ', strColumn = ''' + strColumn + '''' END
	+ CASE WHEN strCaption IS NULL THEN ', strCaption = NULL' ELSE ', strCaption = ''' + strCaption + '''' END
	+ CASE WHEN strFormat IS NULL THEN ', strFormat = NULL' ELSE ', strFormat = ''' + strFormat + '''' END
	+ CASE WHEN strFooter IS NULL THEN ', strFooter = NULL' ELSE ', strFooter = ''' + strFooter + '''' END
	+ CASE WHEN intWidth IS NULL THEN ', intWidth = NULL' ELSE ', intWidth = ' + CAST(intWidth AS NVARCHAR(10)) END
from tblTFReportingComponentField RCF
left join tblTFReportingComponent RC on RC.intReportingComponentId = RCF.intReportingComponentId
where RC.intTaxAuthorityId = @TaxAuthorityId
*/

DECLARE @ReportingComponentOutputDesigners AS TFReportingComponentOutputDesigners

INSERT INTO @ReportingComponentOutputDesigners(
	intScheduleColumnId
	, strFormCode
	, strScheduleCode
	, strType
	, strColumn
	, strCaption
	, strFormat
	, strFooter
	, intWidth
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intScheduleColumnId = 1, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 2, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 3, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 4, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 5, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 6, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 7, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 8, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 12, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 13, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 14, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 15, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 16, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 17, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 18, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 19, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 20, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 21, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 22, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 23, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 24, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 25, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 26, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 27, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 28, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 29, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 30, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 31, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 32, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 33, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 34, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 35, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 36, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 37, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 38, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 39, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 40, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 41, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 42, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 43, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 44, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 45, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 46, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 47, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 48, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 49, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 50, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 51, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 52, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 53, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 54, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 55, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 56, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 57, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 58, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 59, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 60, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 61, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 62, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 63, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 64, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 65, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 66, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 67, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 68, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 69, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 70, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 71, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 72, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 73, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 74, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 75, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 76, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 77, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 78, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 79, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 80, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 81, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 82, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 83, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 84, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 85, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 86, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 87, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 88, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 89, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 90, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 91, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 92, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 93, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 94, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 95, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 96, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 97, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 98, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 99, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 100, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 101, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 102, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 103, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 104, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 105, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 106, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 107, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 108, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 109, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 110, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 111, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 112, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 113, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 114, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 115, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 116, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 117, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 118, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 119, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 120, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 121, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 122, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 123, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 124, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 125, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 126, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 127, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 128, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 129, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 130, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 131, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 132, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 133, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 134, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 135, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 136, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 137, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 138, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 139, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 140, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 141, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 142, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 143, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 144, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 145, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 146, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 147, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 148, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 149, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 150, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 151, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 152, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 153, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 154, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 155, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 156, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 157, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 158, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 159, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 160, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 161, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 162, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 163, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 164, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 165, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 166, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 167, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 168, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 169, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 170, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 171, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 172, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 173, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 174, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 175, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 176, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 177, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 178, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 179, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 180, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 181, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 182, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 183, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 184, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 185, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 186, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 187, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 188, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 189, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 190, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 191, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 192, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 193, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 194, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 195, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 196, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 197, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 198, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 199, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 200, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 201, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 202, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 203, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 204, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 205, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 206, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 207, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 208, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 209, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 210, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 211, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 212, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 213, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 214, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 215, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 216, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 217, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 218, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 219, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 220, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 221, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 222, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 223, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 224, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 225, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 226, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 227, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 228, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 229, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 230, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 231, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 232, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 233, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 234, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 235, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 236, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 237, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 238, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 239, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 240, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 241, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 242, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 243, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 244, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 245, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 246, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 247, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 248, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 249, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 250, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 251, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 252, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 253, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 254, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 255, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 256, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 257, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 258, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 259, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 260, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 261, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 262, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 263, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 264, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 265, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 266, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 267, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 268, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 269, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 270, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 271, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 272, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 273, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 274, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 275, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 276, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 277, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 278, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 279, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 280, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 281, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 282, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 283, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 284, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 285, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 286, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 287, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 288, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 289, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 290, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 291, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 292, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 293, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 294, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 295, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 296, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 297, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 298, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 299, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 300, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 301, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 302, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 303, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 304, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 305, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 306, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 307, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 308, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 309, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 310, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 311, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 312, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 313, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 314, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 315, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 316, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 317, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 318, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 319, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 320, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 321, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 322, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 323, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 324, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 325, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 326, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 327, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 328, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 329, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 330, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 331, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 332, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 333, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 334, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 335, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 336, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 337, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 338, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 339, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 340, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 341, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 342, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 343, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 344, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 345, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 346, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 347, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 348, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 349, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 350, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 351, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 352, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 353, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 354, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 355, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 356, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 357, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 358, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 359, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 360, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 361, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 362, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 363, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 364, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 365, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 366, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 367, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 368, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 369, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 370, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 371, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 372, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 373, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 374, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 375, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 376, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 377, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 378, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 379, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 380, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 381, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 382, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 383, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 384, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 385, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 386, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 387, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 388, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 389, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 390, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 391, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 392, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 393, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 394, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 395, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 396, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 397, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 398, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 399, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 400, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 401, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 402, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 403, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 404, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 405, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 406, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 407, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 408, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 409, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 410, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 411, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 412, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 413, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 414, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 415, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 416, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 417, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 418, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 419, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 420, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 421, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 422, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 423, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 424, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 425, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 426, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 427, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 428, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 429, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 430, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 431, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 432, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 433, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 434, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 435, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 436, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 437, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 438, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 439, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 440, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 441, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 442, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 443, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 444, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 445, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 446, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 447, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 448, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 449, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 450, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 451, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 452, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 453, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 454, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 455, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 456, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 457, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 458, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 459, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 460, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 461, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 462, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 463, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 464, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 465, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 466, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 467, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 468, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 469, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 470, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 471, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 472, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 473, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 474, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 475, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 476, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 477, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 478, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 479, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 480, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 481, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 482, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 483, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 484, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 485, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 486, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 487, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 488, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 489, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 490, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 491, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 492, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 493, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 494, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 495, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 496, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 497, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 498, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 499, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 500, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 501, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 502, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 503, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 504, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 505, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 506, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 507, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 508, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 509, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 510, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 511, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 512, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 513, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 514, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 515, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 516, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 517, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 518, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 519, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 520, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 521, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 522, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 523, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 524, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 525, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 526, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 527, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 528, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 529, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 530, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 531, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 532, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 533, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 534, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 535, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 536, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 537, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 538, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 539, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 540, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 541, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 542, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 543, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 544, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 545, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 546, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 547, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 548, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 549, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 550, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 551, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 552, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 553, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 554, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 555, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 556, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 557, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 558, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 559, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 560, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 561, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 562, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 563, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 564, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 565, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 566, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 567, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 568, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 569, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 570, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 571, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 572, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 573, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 574, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 575, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 576, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 577, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 578, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 579, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 580, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 581, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 582, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 583, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 584, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 585, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 586, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 587, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 588, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 589, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 590, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 591, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 592, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 593, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 594, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 595, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 596, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 597, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 598, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 599, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 600, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 601, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 602, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 603, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 604, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 605, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 606, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 607, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 608, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 609, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 610, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 611, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 612, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 613, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 614, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 615, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 616, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 617, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 618, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 619, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 620, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 621, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 622, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 623, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 624, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 625, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 626, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 627, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 628, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 629, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 630, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 631, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 632, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 633, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 634, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 635, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 636, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 637, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 638, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 639, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 640, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 641, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 642, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 643, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 644, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 645, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 646, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 647, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 648, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 649, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 650, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 651, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 652, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 653, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 654, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 655, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 656, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 657, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 658, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 659, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 660, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 661, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 662, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 663, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 664, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 665, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 666, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 667, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 668, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 669, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 670, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 671, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 672, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 673, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 674, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 675, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 676, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 677, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 678, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 679, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 680, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 681, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 682, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 683, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 684, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 685, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 686, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 687, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 688, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 689, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 690, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 691, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 692, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 693, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 694, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 695, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 696, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 697, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 698, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 699, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 700, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 701, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 702, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 703, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 704, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 705, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 706, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 707, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 708, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 709, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 710, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 711, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 712, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 713, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 714, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 715, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 716, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 717, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 718, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 719, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 720, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 721, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 722, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 723, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 724, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 725, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 726, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 727, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 728, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 729, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 730, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 731, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 732, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 733, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 734, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 735, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 736, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 737, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 738, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 739, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 740, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 741, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 742, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 743, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 744, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 745, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 746, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 747, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 748, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 749, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 750, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 751, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 752, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 753, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 754, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 755, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 756, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 757, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 758, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 759, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'strBillofLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 760, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 761, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 762, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 763, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 764, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 765, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 766, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 767, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 768, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 769, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 770, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 771, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 772, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 773, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 774, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 775, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 776, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 777, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 778, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 779, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 780, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 781, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 782, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 783, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 784, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 785, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 786, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 787, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 788, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 789, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 790, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 791, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 792, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 793, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 794, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 795, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 796, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 797, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 798, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 799, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 800, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 801, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 802, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 803, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 804, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 805, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 806, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 807, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 808, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 809, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 810, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 811, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 812, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 813, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 814, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 815, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 816, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 817, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 818, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 819, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 820, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 821, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 822, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 823, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 824, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 825, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 826, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 827, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 828, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 829, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 830, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 831, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 832, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 833, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 834, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 835, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 836, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 837, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 838, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 839, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 840, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 841, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 842, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 843, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 844, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 845, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 846, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 847, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 848, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 849, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 850, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 851, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 852, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 853, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 854, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 855, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 856, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 857, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 858, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 859, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 860, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 861, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 862, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 863, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 864, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 865, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 866, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 867, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 868, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 869, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 870, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 871, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 872, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 873, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 874, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 875, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 876, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 877, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 878, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 879, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 880, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 881, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strConsignorName', strCaption = 'Consignor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 882, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strConsignorFederalTaxId', strCaption = 'Consigner FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 883, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 884, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 885, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 886, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 887, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 888, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 889, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 890, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'dtmDate', strCaption = 'Document Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 891, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 892, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 893, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 894, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 895, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strConsignorName', strCaption = 'Consignor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 896, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strConsignorFederalTaxId', strCaption = 'Consigner FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 897, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 898, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 899, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 900, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 901, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 902, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 903, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 904, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Document Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 905, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 906, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 907, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 908, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 909, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'strConsignorName', strCaption = 'Consignor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 910, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'strConsignorFederalTaxId', strCaption = 'Consigner FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 911, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 912, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 913, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 914, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 915, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 916, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 917, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 918, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'dtmDate', strCaption = 'Document Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 919, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 920, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'dblGross', strCaption = 'Gross', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 921, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'dblNet', strCaption = 'Net', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 922, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 923, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strConsignorName', strCaption = 'Consignor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 924, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strConsignorFederalTaxId', strCaption = 'Consigner FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 925, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 926, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 927, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 928, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 929, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 930, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 931, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 932, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'dtmDate', strCaption = 'Document Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 933, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 934, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 935, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 936, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 937, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strConsignorName', strCaption = 'Consignor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 938, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strConsignorFederalTaxId', strCaption = 'Consigner FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 939, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 940, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 941, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 942, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 943, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 944, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 945, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 946, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Document Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 947, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 948, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 949, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 950, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 951, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'strConsignorName', strCaption = 'Consignor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 952, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'strConsignorFederalTaxId', strCaption = 'Consigner FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 953, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 954, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 955, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 956, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 957, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 958, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 959, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 960, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'dtmDate', strCaption = 'Document Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 961, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 962, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'dblGross', strCaption = 'Gross', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 963, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'dblNet', strCaption = 'Net', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 964, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 965, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'strConsignorName', strCaption = 'Consignor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 966, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'strConsignorFederalTaxId', strCaption = 'Consigner FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 967, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 968, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 969, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 970, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 971, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 972, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 973, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 974, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'dtmDate', strCaption = 'Document Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 975, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 976, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 977, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 978, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 979, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'strConsignorName', strCaption = 'Consignor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 980, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'strConsignorFederalTaxId', strCaption = 'Consigner FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 981, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 982, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 983, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 984, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 985, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 986, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 987, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 988, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Document Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 989, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 990, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 991, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 992, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 993, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'strConsignorName', strCaption = 'Consignor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 994, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'strConsignorFederalTaxId', strCaption = 'Consigner FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 995, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 996, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 997, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 998, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 999, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1000, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1001, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1002, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'dtmDate', strCaption = 'Document Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1003, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1004, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'dblGross', strCaption = 'Gross', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1005, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'dblNet', strCaption = 'Net', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1006, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1007, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Supplier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1008, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1009, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1010, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Supplier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1011, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasoline', strColumn = 'strVendorLicenseNumber', strCaption = 'Indiana TID', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1012, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Total Gals Purchased', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1013, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasoline', strColumn = 'dblTax', strCaption = 'GUT Paid to Supplier', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1014, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1015, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol', strColumn = 'strVendorName', strCaption = 'Supplier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1016, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1017, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1018, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Supplier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1019, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol', strColumn = 'strVendorLicenseNumber', strCaption = 'Indiana TID', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1020, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol', strColumn = 'dblGross', strCaption = 'Total Gals Purchased', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1021, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol', strColumn = 'dblTax', strCaption = 'GUT Paid to Supplier', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1022, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1023, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1024, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1025, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1026, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1027, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasoline', strColumn = 'dblQtyShipped', strCaption = 'Total Gals Sold', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1028, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasoline', strColumn = 'dblTaxExempt', strCaption = 'Exempt Gals Sold', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1029, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1030, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1031, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1032, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1033, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1034, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', strColumn = 'dblQtyShipped', strCaption = 'Total Gals Sold', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1035, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', strColumn = 'dblTaxExempt', strCaption = 'Exempt Gals Sold', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1036, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', strColumn = 'dblTax', strCaption = 'GUT Collected', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1037, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasoline', strColumn = 'dblTax', strCaption = 'GUT Collected', strFormat = '', strFooter = 'No', intWidth = 0

EXEC uspTFUpgradeReportingComponentOutputDesigners @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponentOutputDesigners = @ReportingComponentOutputDesigners


-- Filing Packet
/* Generate script for Filing Packets. Specify Tax Authority Id to filter out specific Filing Packets only.
select 'UNION ALL SELECT intFilingPacketId = ' + CAST(intFilingPacketId AS NVARCHAR(10))
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN ysnStatus IS NULL THEN ', ysnStatus = NULL' ELSE ', ysnStatus = ' + CAST(ysnStatus AS NVARCHAR) END
	+ CASE WHEN intFrequency IS NULL THEN ', intFrequency = NULL' ELSE ', intFrequency = ' + CAST(intFrequency AS NVARCHAR(10)) END
from tblTFFilingPacket FP
left join tblTFReportingComponent RC on RC.intReportingComponentId = FP.intReportingComponentId
where FP.intTaxAuthorityId = @TaxAuthorityId
*/
DECLARE @FilingPackets AS TFFilingPackets

INSERT INTO @FilingPackets(
	intFilingPacketId
	, strFormCode
	, strScheduleCode
	, strType
	, ysnStatus
	, intFrequency
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intFilingPacketId = 1, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 2, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 3, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 4, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 5, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 6, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 7, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 8, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 9, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 10, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 11, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 12, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 13, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 14, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 15, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 16, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 17, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 18, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 19, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 20, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 21, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 22, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 23, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 24, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 25, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 26, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 27, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 28, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 29, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 30, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 31, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 32, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 33, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 34, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 37, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 40, strFormCode = 'MF-360', strScheduleCode = '', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 41, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasoline', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 42, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 43, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasoline', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 44, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 45, strFormCode = 'GT-103', strScheduleCode = '', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 46, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 47, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 48, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 49, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 50, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 51, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 52, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 53, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 54, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 55, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 56, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 57, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 58, strFormCode = 'SF-900', strScheduleCode = '11', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 59, strFormCode = 'SF-900', strScheduleCode = '', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 60, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 61, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 62, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 63, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 64, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 65, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 66, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 67, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 68, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 69, strFormCode = 'SF-401', strScheduleCode = '', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 70, strFormCode = 'EDI', strScheduleCode = '', strType = 'EDI', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 71, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 72, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 73, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 74, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 75, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 76, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 77, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 78, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 79, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 80, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 81, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 82, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 83, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 84, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 85, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 86, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 87, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', ysnStatus = 1, intFrequency = 2
UNION ALL SELECT intFilingPacketId = 88, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', ysnStatus = 1, intFrequency = 2

EXEC uspTFUpgradeFilingPackets @TaxAuthorityCode = @TaxAuthorityCode, @FilingPackets = @FilingPackets

GO