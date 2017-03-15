-- Declare the Tax Authority Code that will be used all throughout Indiana Default Data
PRINT ('Deploying Indiana Tax Forms')
DECLARE @TaxAuthorityCode NVARCHAR(10) = 'IN'


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
where intTaxAuthorityId = 
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
UNION ALL SELECT intProductCodeId = 2438, strProductCode = 'E10', strDescription = 'Ethanol (11%) Blended', strProductCodeGroup = 'Alcohol', strNote = NULL

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
where intTaxAuthorityId = 
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
where intTaxAuthorityId = 
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
where intTaxAuthorityId = 
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
select 'UNION ALL SELECT intTaxCriteriaId = ' + CAST(intTaxCriteriaId AS NVARCHAR(10))
	+ CASE WHEN TaxCat.strTaxCategory IS NULL THEN ', strTaxCategory = NULL' ELSE ', strTaxCategory = ''' + TaxCat.strTaxCategory + ''''  END
	+ CASE WHEN TaxCat.strState IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + TaxCat.strState + ''''  END
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN strCriteria IS NULL THEN ', strCriteria = NULL' ELSE ', strCriteria = ''' + strCriteria + '''' END
from tblTFReportingComponentCriteria TaxCrit
left join tblTFTaxCategory TaxCat ON TaxCat.intTaxCategoryId = TaxCrit.intTaxCategoryId
left join tblTFReportingComponent RC ON RC.intReportingComponentId = TaxCrit.intReportingComponentId
where RC.intTaxAuthorityId =  and TaxCat.intTaxAuthorityId = 
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
UNION ALL SELECT intTaxCriteriaId = 4, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 5, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 6, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 7, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 8, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 9, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 10, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 11, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 12, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 13, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 14, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 15, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 16, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 17, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 18, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 19, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 20, strTaxCategory = 'IN Excise Tax Gasoline', strState = 'IN', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 26, strTaxCategory = 'IN Excise Tax Diesel Clear', strState = 'IN', strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 27, strTaxCategory = 'IN Excise Tax Diesel Clear', strState = 'IN', strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 28, strTaxCategory = 'IN Excise Tax Diesel Clear', strState = 'IN', strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strCriteria = '<> 0'
UNION ALL SELECT intTaxCriteriaId = 29, strTaxCategory = 'IN Excise Tax Diesel Clear', strState = 'IN', strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strCriteria = '= 0'
UNION ALL SELECT intTaxCriteriaId = 30, strTaxCategory = 'IN Excise Tax Diesel Clear', strState = 'IN', strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strCriteria = '= 0'

EXEC uspTFUpgradeTaxCriteria @TaxAuthorityCode = @TaxAuthorityCode, @TaxCriteria = @TaxCriteria


-- Reporting Component - Base
/* Generate script for Valid Product Codes. Specify Tax Authority Id to filter out specific Valid Product Codes only.
select 'UNION ALL SELECT intValidProductCodeId = ' + CAST(intValidProductCodeId AS NVARCHAR(10))
	+ CASE WHEN PC.strProductCode IS NULL THEN ', strProductCode = NULL' ELSE ', strProductCode = ''' + PC.strProductCode + ''''  END
	+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN strFilter IS NULL THEN ', strFilter = ''''' ELSE ', strFilter = ''' + strFilter + '''' END
from tblTFValidProductCode VPC
left join tblTFProductCode PC ON PC.intProductCodeId= VPC.intProductCode
left join tblTFReportingComponent RC ON RC.intReportingComponentId = VPC.intReportingComponentId
where RC.intTaxAuthorityId =
*/
/* Generate script for Valid Origin States. Specify Tax Authority Id to filter out specific Valid Origin States only.
select 'UNION ALL SELECT intValidOriginStateId = ' + CAST(intValidOriginStateId AS NVARCHAR(10))
	+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + RC.strFormCode + ''''  END
	+ CASE WHEN RC.strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + RC.strScheduleCode + ''''  END
	+ CASE WHEN RC.strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + RC.strType + '''' END
	+ CASE WHEN ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS + ''''  END
	+ CASE WHEN VOS.strType IS NULL THEN ', strStatus = NULL' ELSE ', strStatus = ''' + VOS.strType + ''''  END
	+ CASE WHEN strFilter IS NULL THEN ', strFilter = NULL' ELSE ', strFilter = ''' + strFilter + '''' END
from tblTFValidOriginState VOS
left join tblTFOriginDestinationState ODS ON ODS.intOriginDestinationStateId= VOS.intOriginDestinationStateId
left join tblTFReportingComponent RC ON RC.intReportingComponentId = VOS.intReportingComponentId
where RC.intTaxAuthorityId =
*/
/* Generate script for Valid Destination States. Specify Tax Authority Id to filter out specific Valid Destination States only.
select 'UNION ALL SELECT intValidDestinationStateId = ' + CAST(intValidDestinationStateId AS NVARCHAR(10))
	+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + RC.strFormCode + ''''  END
	+ CASE WHEN RC.strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + RC.strScheduleCode + ''''  END
	+ CASE WHEN RC.strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + RC.strType + '''' END
	+ CASE WHEN ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS + ''''  END
	+ CASE WHEN VDS.strStatus IS NULL THEN ', strStatus = NULL' ELSE ', strStatus = ''' + VDS.strStatus + ''''  END
from tblTFValidDestinationState VDS
left join tblTFOriginDestinationState ODS ON ODS.intOriginDestinationStateId= VDS.intOriginDestinationStateId
left join tblTFReportingComponent RC ON RC.intReportingComponentId = VDS.intReportingComponentId
where RC.intTaxAuthorityId =
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
	, strFilter
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intValidProductCodeId = 1, strProductCode = 'B00', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 2, strProductCode = 'B11', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 3, strProductCode = 'D00', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 4, strProductCode = 'D11', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 5, strProductCode = '226', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 6, strProductCode = '227', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 7, strProductCode = '231', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 8, strProductCode = '232', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 9, strProductCode = '153', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 10, strProductCode = '161', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 11, strProductCode = '167', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 12, strProductCode = '154', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 13, strProductCode = '282', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 14, strProductCode = '283', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 15, strProductCode = '224', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 16, strProductCode = '225', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 17, strProductCode = '285', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 52, strProductCode = 'B00', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 53, strProductCode = 'B11', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 54, strProductCode = 'D00', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 55, strProductCode = 'D11', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 56, strProductCode = '226', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 57, strProductCode = '227', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 58, strProductCode = '231', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 59, strProductCode = '232', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 60, strProductCode = '153', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 61, strProductCode = '161', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 62, strProductCode = '167', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 63, strProductCode = '154', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 64, strProductCode = '282', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 65, strProductCode = '283', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 66, strProductCode = '224', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 67, strProductCode = '225', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 68, strProductCode = '285', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 69, strProductCode = 'B00', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 70, strProductCode = 'B11', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 71, strProductCode = 'D00', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 72, strProductCode = 'D11', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 73, strProductCode = '226', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 74, strProductCode = '227', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 75, strProductCode = '231', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 76, strProductCode = '232', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 77, strProductCode = '153', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 78, strProductCode = '161', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 79, strProductCode = '167', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 80, strProductCode = '154', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 81, strProductCode = '282', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 82, strProductCode = '283', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 83, strProductCode = '224', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 84, strProductCode = '225', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 85, strProductCode = '285', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 86, strProductCode = 'E00', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 87, strProductCode = 'E11', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 88, strProductCode = 'M00', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 89, strProductCode = 'M11', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 90, strProductCode = '125', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 91, strProductCode = '065', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 92, strProductCode = '061', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 93, strProductCode = '090', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 94, strProductCode = '248', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 95, strProductCode = '198', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 96, strProductCode = '249', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 97, strProductCode = '052', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 98, strProductCode = '196', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 99, strProductCode = '058', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 100, strProductCode = '265', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 101, strProductCode = '126', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 102, strProductCode = '059', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 103, strProductCode = '075', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 104, strProductCode = '223', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 105, strProductCode = '121', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 106, strProductCode = '199', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 107, strProductCode = '091', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 108, strProductCode = '076', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 109, strProductCode = '150', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 110, strProductCode = '130', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 111, strProductCode = '145', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 112, strProductCode = '146', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 113, strProductCode = '147', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 114, strProductCode = '148', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 115, strProductCode = '074', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 116, strProductCode = '073', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 117, strProductCode = '100', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 118, strProductCode = '101', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 119, strProductCode = '092', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 120, strProductCode = '093', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 121, strProductCode = 'E00', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 122, strProductCode = 'E11', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 123, strProductCode = 'M00', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 124, strProductCode = 'M11', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 125, strProductCode = '125', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 126, strProductCode = '065', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 127, strProductCode = '061', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 128, strProductCode = 'E00', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 129, strProductCode = 'E11', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 130, strProductCode = 'M00', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 131, strProductCode = 'M11', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 132, strProductCode = '125', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 133, strProductCode = '065', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 134, strProductCode = '061', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 135, strProductCode = '090', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 136, strProductCode = '248', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 137, strProductCode = '198', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 138, strProductCode = '249', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 139, strProductCode = '052', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 140, strProductCode = '196', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 141, strProductCode = '058', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 142, strProductCode = '265', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 143, strProductCode = '126', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 144, strProductCode = '059', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 145, strProductCode = '075', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 146, strProductCode = '223', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 147, strProductCode = '121', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 148, strProductCode = '199', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 149, strProductCode = '091', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 150, strProductCode = '076', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 151, strProductCode = '150', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 152, strProductCode = '130', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 153, strProductCode = '145', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 154, strProductCode = '146', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 155, strProductCode = '147', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 156, strProductCode = '148', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 157, strProductCode = '074', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 158, strProductCode = '073', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 159, strProductCode = '100', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 160, strProductCode = '101', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 161, strProductCode = '092', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 162, strProductCode = '093', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 163, strProductCode = '090', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 164, strProductCode = '248', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 165, strProductCode = '198', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 166, strProductCode = '249', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 167, strProductCode = '052', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 168, strProductCode = '196', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 169, strProductCode = '058', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 170, strProductCode = '265', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 171, strProductCode = '126', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 172, strProductCode = '059', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 173, strProductCode = '075', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 174, strProductCode = '223', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 175, strProductCode = '121', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 176, strProductCode = '199', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 177, strProductCode = '091', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 178, strProductCode = '076', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 179, strProductCode = '150', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 180, strProductCode = '130', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 181, strProductCode = '145', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 182, strProductCode = '146', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 183, strProductCode = '147', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 184, strProductCode = '148', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 185, strProductCode = '074', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 186, strProductCode = '073', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 187, strProductCode = '100', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 188, strProductCode = '101', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 189, strProductCode = '092', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 190, strProductCode = '093', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 191, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 192, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 193, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 194, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 195, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 196, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 197, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 198, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 199, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 200, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 201, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 202, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 203, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 204, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 205, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 206, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 207, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 208, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 209, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 210, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 211, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 212, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 213, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 214, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 215, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 216, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 217, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 218, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 219, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 220, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 221, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 222, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 223, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 224, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 225, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 226, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 227, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 228, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 229, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 230, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 231, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 232, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 233, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 234, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 235, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 236, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 237, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 238, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 239, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 240, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 241, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 242, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 243, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 244, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 245, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 246, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 247, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 248, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 249, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 250, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 251, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 252, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 253, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 254, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 255, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 256, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 257, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 258, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 259, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 260, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 261, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 262, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 263, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 264, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 265, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 266, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 267, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 268, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 269, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 270, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 271, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 272, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 273, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 274, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 275, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 276, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 277, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 278, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 279, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 280, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 281, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 282, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 283, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 284, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 285, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 286, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 287, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 288, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 289, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 290, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 291, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 292, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 293, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 294, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 295, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 296, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 297, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 298, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 299, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 300, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 301, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 302, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 303, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 304, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 305, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 306, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 307, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 308, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 309, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 310, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 311, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 312, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 313, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 314, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 315, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 316, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 317, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 318, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 319, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 320, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 321, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 322, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 323, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 324, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 325, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 334, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 335, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 336, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 337, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 338, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 339, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 340, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 341, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 342, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 343, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 344, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 345, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 346, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 347, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 348, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 349, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 350, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 351, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 352, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 353, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 354, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 355, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 356, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 357, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 358, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 359, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 360, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 361, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 362, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 363, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 364, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 365, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 366, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 367, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 368, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 369, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 370, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 371, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 372, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 373, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 374, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 375, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 376, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 377, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 378, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 379, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 380, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 381, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 382, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 383, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 384, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 385, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 386, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 387, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 388, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 389, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 390, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 391, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 392, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 393, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 394, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 395, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 396, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 397, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 398, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 399, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 400, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 401, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 402, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 403, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 404, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 405, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 406, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 407, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 408, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 409, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 410, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 411, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 412, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 413, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 414, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 415, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 416, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 417, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 418, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 419, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 420, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 421, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 422, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 423, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 424, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 425, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 426, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 427, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 428, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 429, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 430, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 431, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 432, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 433, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 434, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 435, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 436, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 437, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 438, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 439, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 440, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 441, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 442, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 443, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 444, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 445, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 446, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 447, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 448, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 449, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 450, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 451, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 452, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 453, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 454, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 455, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 456, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 457, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 458, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 459, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 460, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 461, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 462, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 463, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 464, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 465, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 466, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 467, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 468, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 469, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 470, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 471, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 472, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 473, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 474, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 475, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 476, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 477, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 478, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 479, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 480, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 481, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 482, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 483, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 484, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 485, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 486, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 487, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 488, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 489, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 490, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 491, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 492, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 493, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 494, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 495, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 496, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 497, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 498, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 499, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 500, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 501, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 502, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 503, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 504, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 505, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 506, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 507, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 508, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 509, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 510, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 511, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 512, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 513, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 514, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 515, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 516, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 517, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 518, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 519, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 520, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 521, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 522, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 523, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 524, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 525, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 526, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 527, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 528, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 529, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 530, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 531, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 532, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 533, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 534, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 535, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 536, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 537, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 538, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 539, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 540, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 541, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 542, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 543, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 544, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 545, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 546, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 547, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 548, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 549, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 550, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 551, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 552, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 553, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 554, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 555, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 556, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 557, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 558, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 559, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 560, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 561, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 562, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 563, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 564, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 572, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 573, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 574, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 575, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 576, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 577, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 578, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 579, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 580, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 581, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 582, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 583, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 584, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 585, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 586, strProductCode = 'E00', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 587, strProductCode = 'E11', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 588, strProductCode = 'M00', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 589, strProductCode = 'M11', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 590, strProductCode = '125', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 591, strProductCode = '065', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 592, strProductCode = '061', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 593, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 594, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 595, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 596, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 597, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 598, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 599, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 600, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 601, strProductCode = '145', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 602, strProductCode = '147', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 603, strProductCode = '073', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 604, strProductCode = '074', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 605, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 606, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 607, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 608, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 609, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 610, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 611, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 612, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 613, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 614, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 615, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 616, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 617, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 618, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 619, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 620, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 621, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 622, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 623, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 624, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 625, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 626, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 627, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 628, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 629, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 630, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 631, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 632, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 633, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 634, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 635, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 636, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 637, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 638, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 639, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 640, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 641, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 642, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 643, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 644, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 645, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 646, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 647, strProductCode = '090', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 648, strProductCode = '248', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 649, strProductCode = '198', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 650, strProductCode = '249', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 651, strProductCode = '052', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 652, strProductCode = '196', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 653, strProductCode = '058', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 654, strProductCode = '265', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 655, strProductCode = '126', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 656, strProductCode = '059', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 657, strProductCode = '075', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 658, strProductCode = '223', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 659, strProductCode = '121', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 660, strProductCode = '199', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 661, strProductCode = '091', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 662, strProductCode = '076', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 663, strProductCode = '231', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 664, strProductCode = '150', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 665, strProductCode = '282', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 666, strProductCode = '152', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 667, strProductCode = '130', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 675, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 676, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 677, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 678, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 679, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 680, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 681, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 682, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 683, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 684, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 685, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 686, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 687, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 688, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 689, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 690, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 691, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 692, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 693, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 694, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 695, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 696, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 697, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 698, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 699, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 700, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 701, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 702, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 703, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 704, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 705, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 706, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 707, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 708, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 709, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 710, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 711, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 712, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 713, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 714, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 715, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 716, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 717, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 718, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 719, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 720, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 721, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 722, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 723, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 724, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 725, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 726, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 727, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 728, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 729, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 730, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 731, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 732, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 733, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 734, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 735, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 736, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 737, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 738, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 739, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 740, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 741, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 742, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 743, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 744, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 745, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 746, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 747, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 748, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 749, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 750, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 751, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 752, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 753, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 754, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 755, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 756, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 757, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 758, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 759, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 760, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 761, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 762, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 763, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 764, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 765, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 766, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 767, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 768, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 769, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 770, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 771, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 772, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 773, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 774, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 775, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 776, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 777, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 778, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 779, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 780, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 781, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 782, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 783, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 784, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 785, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 786, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 787, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 788, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 789, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 790, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 791, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 792, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 793, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 794, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 795, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 796, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 797, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 798, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 799, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 800, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 801, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 802, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 803, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 804, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 805, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 806, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 807, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 808, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 809, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 810, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 811, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 812, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 813, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 814, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 815, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 816, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 817, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 818, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 819, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 820, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 821, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 822, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 823, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 824, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 825, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 826, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 827, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 828, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 829, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 830, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 831, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 832, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 833, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 834, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 835, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 836, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 837, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 838, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 839, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 840, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 841, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 842, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 843, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 844, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 845, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 846, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 847, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 848, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 849, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 850, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 851, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 852, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 853, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 854, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 855, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 856, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 857, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 858, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 859, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 860, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 861, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 862, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 863, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 864, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 865, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 866, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 873, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 874, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 875, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 876, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 879, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 880, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 881, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 882, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 883, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 886, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 887, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 888, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 889, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 890, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 891, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 902, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 903, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 904, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 905, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 906, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 907, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 908, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 909, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 910, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 911, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 912, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 913, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 914, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 915, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 916, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 917, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 918, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 919, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 920, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 921, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 922, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 923, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 924, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 925, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 926, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 927, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 928, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 929, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 930, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 931, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 932, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 933, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 934, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 935, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 936, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 937, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 938, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 939, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 940, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 941, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 942, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 943, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 944, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 945, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 946, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 947, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 948, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 949, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 950, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 951, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 952, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 953, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 954, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 955, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 956, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 957, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 958, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 959, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 960, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 961, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 962, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 963, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 964, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 965, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 966, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 967, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 968, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 969, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 970, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 971, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 972, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 973, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 974, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 975, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 976, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 977, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 978, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 979, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 980, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 981, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 982, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 983, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 984, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 985, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 986, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 987, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 988, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 989, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 990, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 991, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 992, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 993, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 994, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 995, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 996, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 997, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 998, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 999, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1000, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1001, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1002, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1003, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1004, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1005, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1006, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1007, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1008, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1009, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1010, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1011, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1012, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1013, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1014, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1015, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1016, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1017, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1018, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1019, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1020, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1021, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1022, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1023, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1024, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1025, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1026, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1027, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1028, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1029, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1030, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1031, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1032, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1033, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1034, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1035, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1036, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1037, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1038, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1039, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1040, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1041, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1042, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1043, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1044, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1045, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1046, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1047, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1048, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1049, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1050, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1051, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1052, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1053, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1054, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1055, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1056, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1057, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1058, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1059, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1060, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1061, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1062, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1063, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1064, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1065, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1066, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1067, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1068, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1069, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1070, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1071, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1072, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1073, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1074, strProductCode = 'B00', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1075, strProductCode = 'B11', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1076, strProductCode = 'D00', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1077, strProductCode = 'D11', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1078, strProductCode = '226', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1079, strProductCode = '227', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1080, strProductCode = '232', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1081, strProductCode = '153', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1082, strProductCode = '161', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1083, strProductCode = '167', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1084, strProductCode = '154', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1085, strProductCode = '283', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1086, strProductCode = '224', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1087, strProductCode = '225', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1088, strProductCode = '146', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1089, strProductCode = '148', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1090, strProductCode = '285', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1091, strProductCode = '101', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1092, strProductCode = '093', strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strFilter = NULL
UNION ALL SELECT intValidProductCodeId = 1093, strProductCode = '061', strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasoline', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1094, strProductCode = '065', strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasoline', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1095, strProductCode = 'E00', strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1096, strProductCode = 'E11', strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1097, strProductCode = 'M00', strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1098, strProductCode = 'M11', strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1099, strProductCode = '061', strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasoline', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1100, strProductCode = '065', strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasoline', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1101, strProductCode = 'E00', strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1102, strProductCode = 'E11', strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1103, strProductCode = 'M00', strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1104, strProductCode = 'M11', strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1341, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1342, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1343, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1344, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1345, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1346, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1347, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1348, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1349, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1350, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1351, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1352, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1353, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1354, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1355, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1356, strProductCode = 'E10', strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1357, strProductCode = 'E10', strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1358, strProductCode = 'E10', strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1359, strProductCode = 'E10', strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1360, strProductCode = 'E10', strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strFilter = ''
UNION ALL SELECT intValidProductCodeId = 1361, strProductCode = 'E10', strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strFilter = ''

INSERT INTO @ValidOriginStates(
	intValidOriginStateId
	, strFormCode
	, strScheduleCode
	, strType
	, strState
	, strStatus
	, strFilter
)
SELECT intValidOriginStateId = 4, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 5, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 10, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 15, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strState = 'IN', strStatus = '', strFilter = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 16, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strState = 'IN', strStatus = '', strFilter = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 18, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 19, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 23, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 25, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strState = 'IN', strStatus = '', strFilter = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 26, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = '', strFilter = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 27, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = '', strFilter = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 28, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strState = 'IN', strStatus = '', strFilter = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 29, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = '', strFilter = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 30, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = '', strFilter = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 31, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strState = 'IN', strStatus = '', strFilter = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 32, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 33, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 34, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 35, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 36, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 37, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 38, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 39, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 40, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 41, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 42, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 43, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 44, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 45, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 46, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 47, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 48, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 49, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 50, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 51, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 52, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 53, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 54, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 55, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strState = 'IN', strStatus = '', strFilter = 'Include'
UNION ALL SELECT intValidOriginStateId = 56, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strState = 'IN', strStatus = '', strFilter = 'Exclude'
UNION ALL SELECT intValidOriginStateId = 97, strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strState = 'IN', strStatus = '', strFilter = 'Include'

INSERT INTO @ValidDestinationStates(
	intValidDestinationStateId
	, strFormCode
	, strScheduleCode
	, strType
	, strState
	, strStatus
)
SELECT intValidDestinationStateId = 5, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strState = 'IN', strStatus = 'Exclude'
UNION ALL SELECT intValidDestinationStateId = 6, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strState = 'IN', strStatus = 'Exclude'
UNION ALL SELECT intValidDestinationStateId = 11, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strState = 'IN', strStatus = 'Exclude'
UNION ALL SELECT intValidDestinationStateId = 15, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 16, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 17, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 19, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 20, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 24, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 25, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 26, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 27, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 28, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 29, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 30, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 31, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'MI', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 32, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strState = 'MI', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 33, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strState = 'MI', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 34, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'KY', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 35, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strState = 'KY', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 36, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strState = 'KY', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 37, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IL', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 38, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strState = 'IL', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 39, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strState = 'IL', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 40, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'OH', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 41, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strState = 'OH', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 42, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strState = 'OH', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 43, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strState = 'IL', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 44, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strState = 'KY', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 45, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strState = 'MI', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 46, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strState = 'OH', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 47, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strState = 'IL', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 48, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strState = 'KY', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 49, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strState = 'MI', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 50, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strState = 'OH', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 51, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strState = 'IL', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 52, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strState = 'KY', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 53, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strState = 'MI', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 54, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strState = 'OH', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 55, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 81, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 82, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 83, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 84, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 85, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 86, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 87, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 88, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 89, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 90, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 91, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 92, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 93, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 94, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 95, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strState = 'IN', strStatus = 'Include'
UNION ALL SELECT intValidDestinationStateId = 96, strFormCode = 'SF-900', strScheduleCode = '11', strType = '', strState = 'IN', strStatus = 'Include'

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
WHERE RC.intTaxAuthorityId =
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
UNION ALL SELECT intReportTemplateId = 103, strFormCode = 'GT-103', strScheduleCode = '', strType = '', strTemplateItemId = 'GT-103-Summary-005', strReportSection = 'Gasoline Use Tax', intReportItemSequence = '5', intTemplateItemNumber = '5', strDescription = '5. Collection Allowance. Do not calculate this allowance if your return and payment are late. Collection allowance rate is 1%', strScheduleList = '0', strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '1', strLastIndexOf = '', strSegment = 'Summary', intConfigurationSequence = '10'
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
UNION ALL SELECT intReportTemplateId = 82, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-031', strReportSection = 'Section B: Disbursement', intReportItemSequence = '4', intTemplateItemNumber = '10', strDescription = '3. Taxable Gallons Sold or Used (Carry forward to Section 2, Line 3 on front', strScheduleList = '8,9', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 83, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-032', strReportSection = 'Section B: Disbursement', intReportItemSequence = '5', intTemplateItemNumber = '11', strDescription = '4. Gallons Delivered Via Rail, Pipeline, or Vessel to Licensed Suppliers, Tax Not Collected', strScheduleList = '6', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 84, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-033', strReportSection = 'Section B: Disbursement', intReportItemSequence = '6', intTemplateItemNumber = '12', strDescription = '5. Gallons Disbursed on Exchange for Other Suppliers or Permissive Suppliers', strScheduleList = '6X', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 85, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-034', strReportSection = 'Section B: Disbursement', intReportItemSequence = '7', intTemplateItemNumber = '13', strDescription = '6. Gallons Exported by License Holder', strScheduleList = '7', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 86, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-035', strReportSection = 'Section B: Disbursement', intReportItemSequence = '8', intTemplateItemNumber = '14', strDescription = '7. Gallons Sold to Unlicensed Exporters for Export', strScheduleList = '7A', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 87, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-036', strReportSection = 'Section B: Disbursement', intReportItemSequence = '9', intTemplateItemNumber = '15', strDescription = '8. Gallons Sold to Licensed Exporters for Export', strScheduleList = '7B', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 88, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-037', strReportSection = 'Section B: Disbursement', intReportItemSequence = '10', intTemplateItemNumber = '16', strDescription = '9. Gallons of Undyed Fuel Sold to the U.S. Government - Tax Exempt', strScheduleList = '8', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 89, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-038', strReportSection = 'Section B: Disbursement', intReportItemSequence = '11', intTemplateItemNumber = '17', strDescription = '10. Gallons Sold of Tax Exempt Dyed Fuel', strScheduleList = '10', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
UNION ALL SELECT intReportTemplateId = 90, strFormCode = 'SF-900', strScheduleCode = '', strType = '', strTemplateItemId = 'SF-900-Summary-039', strReportSection = 'Section B: Disbursement', intReportItemSequence = '12', intTemplateItemNumber = '18', strDescription = '11. Total Non-Taxable Disbursements (Add Lines 4 through 10; carry forward to Section 2, Line 2 on front of return', strScheduleList = '6,6X,7,7A,7B,8,10', strConfiguration = NULL, ysnConfiguration = '0', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Details', intConfigurationSequence = NULL
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
select 'UNION ALL SELECT intScheduleColumnId = ' + CAST(intScheduleColumnId AS NVARCHAR(10))
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN strColumn IS NULL THEN ', strColumn = NULL' ELSE ', strColumn = ''' + strColumn + '''' END
	+ CASE WHEN strCaption IS NULL THEN ', strCaption = NULL' ELSE ', strCaption = ''' + strCaption + '''' END
	+ CASE WHEN strFormat IS NULL THEN ', strFormat = NULL' ELSE ', strFormat = ''' + strFormat + '''' END
	+ CASE WHEN strFooter IS NULL THEN ', strFooter = NULL' ELSE ', strFooter = ''' + strFooter + '''' END
	+ CASE WHEN intWidth IS NULL THEN ', intWidth = NULL' ELSE ', intWidth = ' + CAST(intWidth AS NVARCHAR(10)) END
from tblTFScheduleFields TRP
left join tblTFReportingComponent RC on RC.intReportingComponentId = TRP.intReportingComponentId
where RC.intTaxAuthorityId =
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
UNION ALL SELECT intScheduleColumnId = 1262, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1263, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1264, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1265, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1266, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1267, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1268, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1269, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1270, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1271, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1272, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1273, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1274, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1275, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1276, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1277, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1278, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1279, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1280, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1281, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1282, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1283, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1284, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1285, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1286, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1287, strFormCode = 'MF-360', strScheduleCode = '1A', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1288, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1289, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1290, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1291, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1292, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1293, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1294, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1295, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1296, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1297, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1298, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1299, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1300, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1301, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1302, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1303, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1304, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1305, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1306, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1307, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1308, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1309, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1310, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1311, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1312, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1313, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1314, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1315, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1316, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1317, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1318, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1319, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1320, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1321, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1322, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1323, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1324, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1325, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1326, strFormCode = 'MF-360', strScheduleCode = '2', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1327, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1328, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1329, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1330, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1331, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1332, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1333, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1334, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1335, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1336, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1337, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1338, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1339, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1340, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1341, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1342, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1343, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1344, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1345, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1346, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1347, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1348, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1349, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1350, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1351, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1352, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1353, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1354, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1355, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1356, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1357, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1358, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1359, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1360, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1361, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1362, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1363, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1364, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1365, strFormCode = 'MF-360', strScheduleCode = '2K', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1366, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1367, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1368, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1369, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1370, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1371, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1372, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1373, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1374, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1375, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1376, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1377, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1378, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1379, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1380, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1381, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1382, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1383, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1384, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1385, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1386, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1387, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1388, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1389, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1390, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1391, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1392, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1393, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1394, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1395, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1396, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1397, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1398, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1399, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1400, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1401, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1402, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1403, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1404, strFormCode = 'MF-360', strScheduleCode = '2X', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1405, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1406, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1407, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1408, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1409, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1410, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1411, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1412, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1413, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1414, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1415, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1416, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1417, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1418, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1419, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1420, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1421, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1422, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1423, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1424, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1425, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1426, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1427, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1428, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1429, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1430, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1431, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1432, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1433, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1434, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1435, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1436, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1437, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1438, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1439, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1440, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1441, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1442, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1443, strFormCode = 'MF-360', strScheduleCode = '3', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1444, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1445, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1446, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1447, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1448, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1449, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1450, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1451, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1452, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1453, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1454, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1455, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1456, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1457, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1458, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1459, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1460, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1461, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1462, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1463, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1464, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1465, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1466, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1467, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1468, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1469, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1470, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1471, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1472, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1473, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1474, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1475, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1476, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1477, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1478, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1479, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1480, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1481, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1482, strFormCode = 'MF-360', strScheduleCode = '4', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9208, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9213, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9214, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9215, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9216, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9217, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9218, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9219, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9220, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9221, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9222, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9223, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9224, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9225, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9226, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9227, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9228, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9229, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9230, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9231, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9232, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9233, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9234, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9235, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9236, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9237, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9238, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9239, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9240, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9241, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9242, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9243, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9244, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9245, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9246, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9247, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9248, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9249, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9250, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9251, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9252, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9253, strFormCode = 'MF-360', strScheduleCode = '5', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9254, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9255, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9256, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9257, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9258, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9259, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9260, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9261, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9262, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9263, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9264, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9265, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9266, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9267, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9268, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9269, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9270, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9271, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9272, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9273, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9274, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9275, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9276, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9277, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9278, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9279, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9280, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9281, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9282, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9283, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9284, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9285, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9286, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9287, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9288, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9289, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9290, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9291, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9292, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9293, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9294, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9295, strFormCode = 'MF-360', strScheduleCode = '6D', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9296, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9297, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9298, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9299, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9300, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9301, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9302, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9303, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9304, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9305, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9306, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9307, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9308, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9309, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9310, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9311, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9312, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9313, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9314, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9315, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9316, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9317, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9318, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9319, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9320, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9321, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9322, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9323, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9324, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9325, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9326, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9327, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9328, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9329, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9330, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9331, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9332, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9333, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9334, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9335, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9336, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9337, strFormCode = 'MF-360', strScheduleCode = '6X', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9338, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9339, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9340, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9341, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9342, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9343, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9344, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9345, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9346, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9347, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9348, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9349, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9350, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9351, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9352, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9353, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9354, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9355, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9356, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9357, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9358, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9359, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9360, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9361, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9362, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9363, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9364, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9365, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9366, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9367, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9368, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9369, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9370, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9371, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9372, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9373, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9374, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9375, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9376, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9377, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9378, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9379, strFormCode = 'MF-360', strScheduleCode = '7MI', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9380, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9381, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9382, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9383, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9384, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9385, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9386, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9387, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9388, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9389, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9390, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9391, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9392, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9393, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9394, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9395, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9396, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9397, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9398, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9399, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9400, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9401, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9402, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9403, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9404, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9405, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9406, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9407, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9408, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9409, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9410, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9411, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9412, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9413, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9414, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9415, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9416, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9417, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9418, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9419, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9420, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9421, strFormCode = 'MF-360', strScheduleCode = '8', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9422, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9423, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9424, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9425, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9426, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9427, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9428, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9429, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9430, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9431, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9432, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9433, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9434, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9435, strFormCode = 'MF-360', strScheduleCode = '10A', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9464, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9465, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9466, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9467, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9468, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9469, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9470, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9471, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9472, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9473, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9474, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9475, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9476, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9477, strFormCode = 'MF-360', strScheduleCode = '10B', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9959, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9960, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Supplier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9961, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9962, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9963, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Supplier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9964, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasoline', strColumn = 'strVendorLicenseNumber', strCaption = 'Indiana TID', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9965, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Total Gals Purchased', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9966, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasoline', strColumn = 'dblTax', strCaption = 'GUT Paid to Supplier', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10343, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10344, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol', strColumn = 'strVendorName', strCaption = 'Supplier Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10345, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10346, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10347, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol', strColumn = 'strVendorFederalTaxId', strCaption = 'Supplier FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10348, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol', strColumn = 'strVendorLicenseNumber', strCaption = 'Indiana TID', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10349, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol', strColumn = 'dblGross', strCaption = 'Total Gals Purchased', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10350, strFormCode = 'GT-103', strScheduleCode = '1R', strType = 'Gasohol', strColumn = 'dblTax', strCaption = 'GUT Paid to Supplier', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10351, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10352, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10353, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10354, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10355, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10357, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasoline', strColumn = 'dblQtyShipped', strCaption = 'Total Gals Sold', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10358, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Exempt Gals Sold', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 11401, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasoline', strColumn = 'dblTax', strCaption = 'GUT Collected', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10359, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10360, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10361, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10362, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10363, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10364, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', strColumn = 'dblQtyShipped', strCaption = 'Total Gals Sold', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10365, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', strColumn = 'dblGross', strCaption = 'Exempt Gals Sold', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 10366, strFormCode = 'GT-103', strScheduleCode = '2D', strType = 'Gasohol', strColumn = 'dblTax', strCaption = 'GUT Collected', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1483, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1484, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1485, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1486, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1487, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1488, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1489, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1490, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1491, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1492, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1493, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1494, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1495, strFormCode = 'SF-900', strScheduleCode = '1', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1496, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1497, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1498, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1499, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1500, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1501, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1502, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1503, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1504, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1505, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1506, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1507, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1508, strFormCode = 'SF-900', strScheduleCode = '2E', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1509, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1510, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1511, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1512, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1513, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1514, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1515, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1516, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1517, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1518, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1519, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1520, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1521, strFormCode = 'SF-900', strScheduleCode = '2K', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1522, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1523, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1524, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1525, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1526, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1527, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1528, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1529, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1530, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1531, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1532, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1533, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 1534, strFormCode = 'SF-900', strScheduleCode = '3', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9478, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9479, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9480, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9481, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9482, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9483, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9484, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9485, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9486, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9487, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9488, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9489, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9490, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9491, strFormCode = 'SF-900', strScheduleCode = '5', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9492, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9493, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9494, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9495, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9496, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9497, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9498, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9499, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9500, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9501, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9502, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9503, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9504, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9505, strFormCode = 'SF-900', strScheduleCode = '6', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9506, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9507, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9508, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9509, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9510, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9511, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9512, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9513, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9514, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9515, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9516, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9517, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9518, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9519, strFormCode = 'SF-900', strScheduleCode = '6X', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9520, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9521, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9522, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9523, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9524, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9525, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9526, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9527, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9528, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9529, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9530, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9531, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9532, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9533, strFormCode = 'SF-900', strScheduleCode = '7IL', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9534, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9535, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9536, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9537, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9538, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9539, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9540, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9541, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9542, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9543, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9544, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9545, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9546, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9547, strFormCode = 'SF-900', strScheduleCode = '7AIL', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9548, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9549, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9550, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9551, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9552, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9553, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9554, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9555, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9556, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9557, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9558, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9559, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9560, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9561, strFormCode = 'SF-900', strScheduleCode = '7BIL', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9562, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9563, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9564, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9565, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9566, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9567, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9568, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9569, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9570, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9571, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9572, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9573, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9574, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9575, strFormCode = 'SF-900', strScheduleCode = '8', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9576, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9577, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9578, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9579, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9580, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9581, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9582, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9583, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9584, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9585, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9586, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9587, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9588, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9589, strFormCode = 'SF-900', strScheduleCode = '10', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9833, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9834, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strConsignorName', strCaption = 'Consignor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9835, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strConsignorFederalTaxId', strCaption = 'Consigner FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9836, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9837, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9838, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9839, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9840, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9841, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9842, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9843, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'dtmDate', strCaption = 'Document Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9844, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9845, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9846, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9847, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9848, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strConsignorName', strCaption = 'Consignor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9849, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strConsignorFederalTaxId', strCaption = 'Consigner FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9850, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9851, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9852, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9853, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9854, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9855, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9856, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9857, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Document Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9858, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9859, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9860, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9861, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9862, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'strConsignorName', strCaption = 'Consignor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9863, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'strConsignorFederalTaxId', strCaption = 'Consigner FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9864, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9865, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9866, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9867, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9868, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9869, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9870, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9871, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'dtmDate', strCaption = 'Document Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9872, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9873, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'dblGross', strCaption = 'Gross', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9874, strFormCode = 'SF-401', strScheduleCode = '1A', strType = 'Other Products', strColumn = 'dblNet', strCaption = 'Net', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9875, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9876, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strConsignorName', strCaption = 'Consignor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9877, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strConsignorFederalTaxId', strCaption = 'Consigner FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9878, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9879, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9880, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9881, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9882, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9883, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9884, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9885, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'dtmDate', strCaption = 'Document Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9886, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9887, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9888, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9889, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9890, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strConsignorName', strCaption = 'Consignor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9891, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strConsignorFederalTaxId', strCaption = 'Consigner FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9892, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9893, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9894, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9895, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9896, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9897, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9898, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9899, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Document Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9900, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9901, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9902, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9903, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9904, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'strConsignorName', strCaption = 'Consignor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9905, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'strConsignorFederalTaxId', strCaption = 'Consigner FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9906, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9907, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9908, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9909, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9910, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9911, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9912, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9913, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'dtmDate', strCaption = 'Document Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9914, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9915, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'dblGross', strCaption = 'Gross', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9916, strFormCode = 'SF-401', strScheduleCode = '2A', strType = 'Other Products', strColumn = 'dblNet', strCaption = 'Net', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9917, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9918, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'strConsignorName', strCaption = 'Consignor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9919, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'strConsignorFederalTaxId', strCaption = 'Consigner FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9920, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9921, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9922, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9923, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9924, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9925, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9926, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9927, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'dtmDate', strCaption = 'Document Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9928, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9929, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'dblGross', strCaption = 'Gross', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9930, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Special Fuel', strColumn = 'dblNet', strCaption = 'Net', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9931, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9932, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'strConsignorName', strCaption = 'Consignor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9933, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'strConsignorFederalTaxId', strCaption = 'Consigner FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9934, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9935, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9936, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9937, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9938, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9939, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9940, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9941, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'dtmDate', strCaption = 'Document Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9942, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9943, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'dblGross', strCaption = 'Gross', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9944, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Gasoline', strColumn = 'dblNet', strCaption = 'Net', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9945, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9946, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'strConsignorName', strCaption = 'Consignor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9947, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'strConsignorFederalTaxId', strCaption = 'Consigner FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9948, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'strVendorName', strCaption = 'Seller Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9949, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'strVendorFederalTaxId', strCaption = 'Seller FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9950, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9951, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9952, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'strCustomerName', strCaption = 'Customer Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9953, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9954, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9955, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'dtmDate', strCaption = 'Document Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9956, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9957, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'dblGross', strCaption = 'Gross', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9958, strFormCode = 'SF-401', strScheduleCode = '3A', strType = 'Other Products', strColumn = 'dblNet', strCaption = 'Net', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9590, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9591, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9592, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9593, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9594, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9595, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9596, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9597, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9598, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9599, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9600, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9601, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9602, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9603, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9604, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9605, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9606, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9607, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9608, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9609, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9610, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9611, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9612, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9613, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9614, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9615, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9616, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9617, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9618, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9619, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9620, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9621, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9622, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9623, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9624, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9625, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9626, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9627, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9628, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9629, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9630, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9631, strFormCode = 'MF-360', strScheduleCode = '7KY', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9632, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9633, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9634, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9635, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9636, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9637, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9638, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9639, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9640, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9641, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9642, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9643, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9644, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9645, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9646, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9647, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9648, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9649, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9650, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9651, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9652, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9653, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9654, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9655, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9656, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9657, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9658, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9659, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9660, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9661, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9662, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9663, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9664, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9665, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9666, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9667, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9668, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9669, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9670, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9671, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9672, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9673, strFormCode = 'MF-360', strScheduleCode = '7IL', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9674, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9675, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9676, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9677, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9678, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9679, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9680, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9681, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9682, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9683, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9684, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9685, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9686, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9687, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'Gasoline / Aviation Gasoline / Gasohol', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9688, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9689, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9690, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9691, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9692, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9693, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9694, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9695, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9696, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9697, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9698, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9699, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9700, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9701, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'K-1 / K-2 Kerosene', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9702, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9703, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9704, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9705, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9706, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9707, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9708, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'strTerminalControlNumber', strCaption = 'Terminal', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9709, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'strCustomerName', strCaption = 'Sold To', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9710, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'strCustomerFederalTaxId', strCaption = 'Customer FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9711, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'dtmDate', strCaption = 'Date', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9712, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'strInvoiceNumber', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9713, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9714, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9715, strFormCode = 'MF-360', strScheduleCode = '7OH', strType = 'All Other Products', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9716, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9717, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9718, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9719, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9720, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9721, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9722, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9723, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9724, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9725, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9726, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9727, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9728, strFormCode = 'SF-900', strScheduleCode = '7KY', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9729, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9730, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9731, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9732, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9733, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9734, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9735, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9736, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9737, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9738, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9739, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9740, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9741, strFormCode = 'SF-900', strScheduleCode = '7MI', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9742, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9743, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9744, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9745, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9746, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9747, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9748, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9749, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9750, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9751, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9752, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9753, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9754, strFormCode = 'SF-900', strScheduleCode = '7OH', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9755, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9756, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9757, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9758, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9759, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9760, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9761, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9762, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9763, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9764, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9765, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9766, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9767, strFormCode = 'SF-900', strScheduleCode = '7AKY', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9768, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9769, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9770, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9771, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9772, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9773, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9774, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9775, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9776, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9777, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9778, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9779, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9780, strFormCode = 'SF-900', strScheduleCode = '7AMI', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9781, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9782, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9783, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9784, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9785, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9786, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9787, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9788, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9789, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9790, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9791, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9792, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9793, strFormCode = 'SF-900', strScheduleCode = '7AOH', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9794, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9795, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9796, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9797, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9798, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9799, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9800, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9801, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9802, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9803, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9804, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9805, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9806, strFormCode = 'SF-900', strScheduleCode = '7BKY', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9807, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9808, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9809, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9810, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9811, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9812, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9813, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9814, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9815, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9816, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9817, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9818, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9819, strFormCode = 'SF-900', strScheduleCode = '7BMI', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9820, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'strProductCode', strCaption = 'Product Code', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9821, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'strTransporterName', strCaption = 'Transporter Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9822, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'strTransporterFederalTaxId', strCaption = 'Transporter FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9823, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'strTransportationMode', strCaption = 'Mode', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9824, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'strOriginState', strCaption = 'Origin State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9825, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'strDestinationState', strCaption = 'Destination State', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9826, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'strVendorName', strCaption = 'Vendor Name', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9827, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'strVendorFederalTaxId', strCaption = 'Vendor FEIN', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9828, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'dtmDate', strCaption = 'Date Received', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9829, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'strBillOfLading', strCaption = 'Document Number', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9830, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'dblNet', strCaption = 'Net Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9831, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'dblGross', strCaption = 'Gross Gals', strFormat = '', strFooter = 'No', intWidth = 0
UNION ALL SELECT intScheduleColumnId = 9832, strFormCode = 'SF-900', strScheduleCode = '7BOH', strType = '', strColumn = 'dblBillQty', strCaption = 'Billed Gals', strFormat = '', strFooter = 'No', intWidth = 0

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
where FP.intTaxAuthorityId = 
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