-- Tax Category
/* Generate script for Tax Categories. Specify Tax Authority Id to filter out specific Tax Categories only.
select 'UNION ALL SELECT intTaxCategoryId = ' + CAST(0 AS NVARCHAR(10))
	+ CASE WHEN strState IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + strState + ''''  END
	+ CASE WHEN strTaxCategory IS NULL THEN ', strTaxCategory = NULL' ELSE ', strTaxCategory = ''' + strTaxCategory + ''''  END
--	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(intMasterId, '') = '' THEN intTaxCategoryId ELSE intMasterId END) AS NVARCHAR(20)) -- Old Format
	+ ', intMasterId = ' + CASE WHEN intMasterId IS NULL THEN CAST(@TaxAuthorityId AS NVARCHAR(20)) + CAST(intTaxCategoryId AS NVARCHAR(20)) ELSE CAST(intMasterId AS NVARCHAR(20)) END -- First 2 digit for TaxAuthorityCodeID
from tblTFTaxCategory
where intTaxAuthorityId = @TaxAuthorityId
*/

PRINT ('Deploying AR Tax Category')

DECLARE @TaxCategoryAR AS TFTaxCategory

INSERT INTO @TaxCategoryAR(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
SELECT intTaxCategoryId = 0, strState = 'AR', strTaxCategory = 'AR Excise Tax Gasoline', intMasterId = 4170
UNION ALL SELECT intTaxCategoryId = 0, strState = 'AR', strTaxCategory = 'AR Excise Tax Diesel Clear', intMasterId = 4171
UNION ALL SELECT intTaxCategoryId = 0, strState = 'AR', strTaxCategory = 'AR Excise Tax LPG', intMasterId = 4172
UNION ALL SELECT intTaxCategoryId = 0, strState = 'AR', strTaxCategory = 'AR Excise Tax CNG', intMasterId = 4173
UNION ALL SELECT intTaxCategoryId = 0, strState = 'AR', strTaxCategory = 'AR Excise Tax Diesel Dyed', intMasterId = 4174

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = 'AR', @TaxCategories = @TaxCategoryAR

DELETE @TaxCategoryAR

GO


PRINT ('Deploying ID Tax Category')

DECLARE @TaxCategoryID AS TFTaxCategory

INSERT INTO @TaxCategoryID(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
SELECT intTaxCategoryId = 0, strState = 'ID', strTaxCategory = 'ID Excise Tax Diesel Clear', intMasterId = 12147
UNION ALL SELECT intTaxCategoryId = 0, strState = 'ID', strTaxCategory = 'ID Excise Tax Gasoline', intMasterId = 12148
UNION ALL SELECT intTaxCategoryId = 0, strState = 'ID', strTaxCategory = 'ID Excise Tax Propane', intMasterId = 12149
UNION ALL SELECT intTaxCategoryId = 0, strState = 'ID', strTaxCategory = 'ID Excise Tax LNG', intMasterId = 12150
UNION ALL SELECT intTaxCategoryId = 0, strState = 'ID', strTaxCategory = 'ID Excise Tax CNG', intMasterId = 12151
UNION ALL SELECT intTaxCategoryId = 0, strState = 'ID', strTaxCategory = 'ID Excise Tax Aviation Gasoline', intMasterId = 12152
UNION ALL SELECT intTaxCategoryId = 0, strState = 'ID', strTaxCategory = 'ID Excise Tax Jet Fuel', intMasterId = 12153

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = 'ID', @TaxCategories = @TaxCategoryID

DELETE @TaxCategoryID

GO


PRINT ('Deploying IL Tax Category')

DECLARE @TaxCategoryIL AS TFTaxCategory

INSERT INTO @TaxCategoryIL(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
SELECT intTaxCategoryId = 0, strState = 'IL', strTaxCategory = 'IL Excise Tax Gasoline/Gasohol', intMasterId = 135
UNION ALL SELECT intTaxCategoryId = 0, strState = 'IL', strTaxCategory = 'IL Excise Tax Diesel Clear', intMasterId = 136
UNION ALL SELECT intTaxCategoryId = 0, strState = 'IL', strTaxCategory = 'IL Excise Tax Combustible Gases', intMasterId = 1335
UNION ALL SELECT intTaxCategoryId = 0, strState = 'IL', strTaxCategory = 'IL Underground Storage Tank (UST)', intMasterId = 1336
UNION ALL SELECT intTaxCategoryId = 0, strState = 'IL', strTaxCategory = 'IL Environment Impact Fee (EIF)', intMasterId = 1337
UNION ALL SELECT intTaxCategoryId = 0, strState = 'IL', strTaxCategory = 'IL Excise Tax Diesel Dyed', intMasterId = 13125

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = 'IL', @TaxCategories = @TaxCategoryIL

DELETE @TaxCategoryIL

GO


PRINT ('Deploying IN Tax Category')

DECLARE @TaxCategoryIN AS TFTaxCategory

INSERT INTO @TaxCategoryIN(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
SELECT intTaxCategoryId = 0, strState = 'IN', strTaxCategory = 'IN Excise Tax Gasoline', intMasterId = 141
UNION ALL SELECT intTaxCategoryId = 0, strState = 'IN', strTaxCategory = 'IN Excise Tax Diesel Clear', intMasterId = 142
UNION ALL SELECT intTaxCategoryId = 0, strState = 'IN', strTaxCategory = 'IN Inspection Fee', intMasterId = 143
UNION ALL SELECT intTaxCategoryId = 0, strState = 'IN', strTaxCategory = 'IN Gasoline Use Tax (GUT)', intMasterId = 144
UNION ALL SELECT intTaxCategoryId = 0, strState = 'IN', strTaxCategory = 'IN Excise Tax Diesel Dyed', intMasterId = 145

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = 'IN', @TaxCategories = @TaxCategoryIN

DELETE @TaxCategoryIN

GO


PRINT ('Deploying KS Tax Category')

DECLARE @TaxCategoryKS AS TFTaxCategory

INSERT INTO @TaxCategoryKS(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
SELECT intTaxCategoryId = 0, strState = 'KS', strTaxCategory = 'KS Excise Tax Gasoline', intMasterId = 16181
UNION ALL SELECT intTaxCategoryId = 0, strState = 'KS', strTaxCategory = 'KS Excise Tax Gasohol', intMasterId = 16182
UNION ALL SELECT intTaxCategoryId = 0, strState = 'KS', strTaxCategory = 'KS Excise Tax Diesel Clear', intMasterId = 16183

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = 'KS', @TaxCategories = @TaxCategoryKS

DELETE @TaxCategoryKS

GO


PRINT ('Deploying KY Tax Category')

DECLARE @TaxCategoryKY AS TFTaxCategory

INSERT INTO @TaxCategoryKY(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
SELECT intTaxCategoryId = 0, strState = 'KY', strTaxCategory = 'KY Excise Tax Gasoline', intMasterId = 17108
UNION ALL SELECT intTaxCategoryId = 0, strState = 'KY', strTaxCategory = 'KY Excise Tax Diesel Clear', intMasterId = 17109
UNION ALL SELECT intTaxCategoryId = 0, strState = 'KY', strTaxCategory = 'KY Excise Tax Special Fuels', intMasterId = 17110
UNION ALL SELECT intTaxCategoryId = 0, strState = 'KY', strTaxCategory = 'KY Excise Tax LPG', intMasterId = 17111

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = 'KY', @TaxCategories = @TaxCategoryKY

DELETE @TaxCategoryKY

GO


PRINT ('Deploying LA Tax Category')

DECLARE @TaxCategoryLA AS TFTaxCategory

INSERT INTO @TaxCategoryLA(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
SELECT intTaxCategoryId = 0, strState = 'LA', strTaxCategory = 'LA Excise Tax Gasoline', intMasterId = 182059
UNION ALL SELECT intTaxCategoryId = 0, strState = 'LA', strTaxCategory = 'LA Excise Tax Gasohol', intMasterId = 182060
UNION ALL SELECT intTaxCategoryId = 0, strState = 'LA', strTaxCategory = 'LA Excise Tax Diesel Clear', intMasterId = 182061
UNION ALL SELECT intTaxCategoryId = 0, strState = 'LA', strTaxCategory = 'LA Inspection Fee', intMasterId = 182062

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = 'LA', @TaxCategories = @TaxCategoryLA

DELETE @TaxCategoryLA

GO


PRINT ('Deploying MI Tax Category')

DECLARE @TaxCategoryMI AS TFTaxCategory

INSERT INTO @TaxCategoryMI(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
SELECT intTaxCategoryId = 58, strState = 'MI', strTaxCategory = 'MI Excise Tax Gasoline', intMasterId = 229
UNION ALL SELECT intTaxCategoryId = 59, strState = 'MI', strTaxCategory = 'MI Excise Tax Diesel Clear', intMasterId = 2210
UNION ALL SELECT intTaxCategoryId = 60, strState = 'MI', strTaxCategory = 'MI Inspection Fee', intMasterId = 2211
UNION ALL SELECT intTaxCategoryId = 61, strState = 'MI', strTaxCategory = 'MI Excise Tax Diesel Dyed', intMasterId = 222058
UNION ALL SELECT intTaxCategoryId = 0, strState = 'MI', strTaxCategory = 'MI Excise Tax Propane', intMasterId = 222059	

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = 'MI', @TaxCategories = @TaxCategoryMI

DELETE @TaxCategoryMI

GO

PRINT ('Deploying MN Tax Category')

DECLARE @TaxCategoryMN AS TFTaxCategory

INSERT INTO @TaxCategoryMN(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
SELECT intTaxCategoryId = 0, strState = 'MN', strTaxCategory = 'MN Excise Tax Gasoline/Alcohol', intMasterId = 23158
UNION ALL SELECT intTaxCategoryId = 0, strState = 'MN', strTaxCategory = 'MN Excise Tax E-85', intMasterId = 23159
UNION ALL SELECT intTaxCategoryId = 0, strState = 'MN', strTaxCategory = 'MN Excise Tax Diesel Clear', intMasterId = 23160
UNION ALL SELECT intTaxCategoryId = 0, strState = 'MN', strTaxCategory = 'MN Excise Tax Aviation Gas', intMasterId = 23161
UNION ALL SELECT intTaxCategoryId = 0, strState = 'MN', strTaxCategory = 'MN Excise Tax Jet Fuel', intMasterId = 23162
UNION ALL SELECT intTaxCategoryId = 0, strState = 'MN', strTaxCategory = 'MN Excise Tax LPG (Propane)', intMasterId = 23164
UNION ALL SELECT intTaxCategoryId = 0, strState = 'MN', strTaxCategory = 'MN Excise Tax CNG', intMasterId = 23165
UNION ALL SELECT intTaxCategoryId = 0, strState = 'MN', strTaxCategory = 'MN Excise Tax LNG', intMasterId = 23166

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = 'MN', @TaxCategories = @TaxCategoryMN

DELETE @TaxCategoryMN

GO


PRINT ('Deploying MS Tax Category')

DECLARE @TaxCategoryMS AS TFTaxCategory

INSERT INTO @TaxCategoryMS(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
SELECT intTaxCategoryId = 49, strState = 'MS', strTaxCategory = 'MS Excise Tax Automotive Gasoline', intMasterId = 241035
UNION ALL SELECT intTaxCategoryId = 50, strState = 'MS', strTaxCategory = 'MS Excise Tax Aviation Gasoline', intMasterId = 241036
UNION ALL SELECT intTaxCategoryId = 51, strState = 'MS', strTaxCategory = 'MS Excise Tax Undyed Diesel', intMasterId = 241037
UNION ALL SELECT intTaxCategoryId = 52, strState = 'MS', strTaxCategory = 'MS Excise Tax Dyed Diesel', intMasterId = 241038
UNION ALL SELECT intTaxCategoryId = 53, strState = 'MS', strTaxCategory = 'MS Excise Tax Jet Fuel', intMasterId = 241039
UNION ALL SELECT intTaxCategoryId = 54, strState = 'MS', strTaxCategory = 'MS Excise Tax Fuel Oil and Other Special Fuel', intMasterId = 241058

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = 'MS', @TaxCategories = @TaxCategoryMS

DELETE @TaxCategoryMS

GO

PRINT ('Deploying MT Tax Category')

DECLARE @TaxCategoryMT AS TFTaxCategory

INSERT INTO @TaxCategoryMT(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
SELECT intTaxCategoryId = 0, strState = 'MT', strTaxCategory = 'MT Excise Tax Gasoline Gasohol Ethanol', intMasterId = 26143
UNION ALL SELECT intTaxCategoryId = 0, strState = 'MT', strTaxCategory = 'MT Excise Tax Aviation', intMasterId = 26144
UNION ALL SELECT intTaxCategoryId = 0, strState = 'MT', strTaxCategory = 'MT Excise Tax Diesel Clear', intMasterId = 26145

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = 'MT', @TaxCategories = @TaxCategoryMT

DELETE @TaxCategoryMT

GO


PRINT ('Deploying NC Tax Category')

DECLARE @TaxCategoryNC AS TFTaxCategory

INSERT INTO @TaxCategoryNC(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intTaxCategoryId = 62, strState = 'NC', strTaxCategory = 'NC Excise Tax Gasoline', intMasterId = 332099
UNION ALL SELECT intTaxCategoryId = 63, strState = 'NC', strTaxCategory = 'NC Excise Tax Diesel Clear', intMasterId = 332100
UNION ALL SELECT intTaxCategoryId = 139, strState = 'NC', strTaxCategory = 'NC Excise Tax Alternative Fuels', intMasterId = 33139

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = 'NC', @TaxCategories = @TaxCategoryNC

DELETE @TaxCategoryNC

GO


PRINT ('Deploying NE Tax Category')

DECLARE @TaxCategoryNE AS TFTaxCategory

INSERT INTO @TaxCategoryNE(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
SELECT intTaxCategoryId = 0, strState = 'NE', strTaxCategory = 'NE Excise Tax Gasoline', intMasterId = 2718
UNION ALL SELECT intTaxCategoryId = 0, strState = 'NE', strTaxCategory = 'NE Excise Tax Diesel Clear', intMasterId = 2719
UNION ALL SELECT intTaxCategoryId = 0, strState = 'NE', strTaxCategory = 'NE PRF Fee Gasoline', intMasterId = 2720
UNION ALL SELECT intTaxCategoryId = 0, strState = 'NE', strTaxCategory = 'NE PRF Fee Diesel Clear', intMasterId = 2721
UNION ALL SELECT intTaxCategoryId = 0, strState = 'NE', strTaxCategory = 'NE Excise Tax Gasohol', intMasterId = 2724
UNION ALL SELECT intTaxCategoryId = 0, strState = 'NE', strTaxCategory = 'NE Excise Tax Ethanol', intMasterId = 2725
UNION ALL SELECT intTaxCategoryId = 0, strState = 'NE', strTaxCategory = 'NE Excise Tax Compressed Fuels', intMasterId = 2726
UNION ALL SELECT intTaxCategoryId = 0, strState = 'NE', strTaxCategory = 'NE Excise Tax Aviation Gasoline', intMasterId = 2727
UNION ALL SELECT intTaxCategoryId = 0, strState = 'NE', strTaxCategory = 'NE Excise Tax Jet Fuel', intMasterId = 2728
UNION ALL SELECT intTaxCategoryId = 0, strState = 'NE', strTaxCategory = 'NE PRF Fee Gasohol', intMasterId = 2729
UNION ALL SELECT intTaxCategoryId = 0, strState = 'NE', strTaxCategory = 'NE PRF Fee Ethanol', intMasterId = 2730
UNION ALL SELECT intTaxCategoryId = 0, strState = 'NE', strTaxCategory = 'NE PRF Fee Aviation Gasoline', intMasterId = 2731
UNION ALL SELECT intTaxCategoryId = 0, strState = 'NE', strTaxCategory = 'NE PRF Fee Jet Fuel', intMasterId = 2733
UNION ALL SELECT intTaxCategoryId = 0, strState = 'NE', strTaxCategory = 'NE PRF Fee All Other Petroleum Products', intMasterId = 2734

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = 'NE', @TaxCategories = @TaxCategoryNE

DELETE @TaxCategoryNE

GO


PRINT ('Deploying NM Tax Category')

DECLARE @TaxCategoryNM AS TFTaxCategory

INSERT INTO @TaxCategoryNM(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
SELECT intTaxCategoryId = 0, strState = 'NM', strTaxCategory = 'NM Excise Tax Alternative Fuels', intMasterId = 31126
UNION ALL SELECT intTaxCategoryId = 0, strState = 'NM', strTaxCategory = 'NM Excise Tax Gasoline', intMasterId = 31127
UNION ALL SELECT intTaxCategoryId = 0, strState = 'NM', strTaxCategory = 'NM Excise Tax Diesel Clear', intMasterId = 31128	
	
EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = 'NM', @TaxCategories = @TaxCategoryNM

DELETE @TaxCategoryNM

GO


PRINT ('Deploying OH Tax Category')

DECLARE @TaxCategoryOH AS TFTaxCategory

INSERT INTO @TaxCategoryOH(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
SELECT intTaxCategoryId = 0, strState = 'OH', strTaxCategory = 'OH Excise Tax Gasoline', intMasterId = 3599
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OH', strTaxCategory = 'OH Excise Tax Clear Diesel', intMasterId = 35100
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OH', strTaxCategory = 'OH Excise Tax Low Sulfur Dyed Diesel', intMasterId = 35101
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OH', strTaxCategory = 'OH Excise Tax High Sulfur Dyed Diesel', intMasterId = 35102
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OH', strTaxCategory = 'OH Excise Tax Kerosene', intMasterId = 35103
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OH', strTaxCategory = 'OH Excise Tax CNG', intMasterId = 35104
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OH', strTaxCategory = 'OH Excise Tax LNG', intMasterId = 35105
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OH', strTaxCategory = 'OH Excise Tax Propane', intMasterId = 35106
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OH', strTaxCategory = 'OH Excise Tax Other', intMasterId = 35107

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = 'OH', @TaxCategories = @TaxCategoryOH

DELETE @TaxCategoryOH

GO


PRINT ('Deploying OK Tax Category')

DECLARE @TaxCategoryOK AS TFTaxCategory

INSERT INTO @TaxCategoryOK(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
SELECT intTaxCategoryId = 0, strState = 'OK', strTaxCategory = 'OK Excise Tax Gasoline', intMasterId = 36175
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OK', strTaxCategory = 'OK Excise Tax E85', intMasterId = 36176
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OK', strTaxCategory = 'OK Excise Tax Diesel Clear', intMasterId = 36177
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OK', strTaxCategory = 'OK Excise Tax Biodiesel Clear', intMasterId = 36178
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OK', strTaxCategory = 'OK Excise Tax Aviation Gas', intMasterId = 36179
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OK', strTaxCategory = 'OK Excise Tax Jet Fuel', intMasterId = 36180

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = 'OK', @TaxCategories = @TaxCategoryOK

DELETE @TaxCategoryOK

GO


PRINT ('Deploying OR Tax Category')

DECLARE @TaxCategoryOR AS TFTaxCategory

INSERT INTO @TaxCategoryOR(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR Excise Tax Gasoline', intMasterId = 372063
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR Excise Tax Aviation Gasoline', intMasterId = 372064
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR Excise Tax Jet Fuel', intMasterId = 372065
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR Use Fuel Tax', intMasterId = 372066
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Astoria Gasoline', intMasterId = 372067
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Astoria Diesel', intMasterId = 372068
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Canby Gasoline', intMasterId = 372069
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Canby Diesel', intMasterId = 372070
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Coburg Gasoline', intMasterId = 372071
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Coquille Gasoline', intMasterId = 372072
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Coquille Diesel', intMasterId = 372073
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Cottage Grove Gasoline', intMasterId = 372074
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Cottage Grove Diesel', intMasterId = 372075
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Eugene Gasoline', intMasterId = 372076
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Eugene Diesel', intMasterId = 372077
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Hood River Gasoline', intMasterId = 372078
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Hood River Diesel', intMasterId = 372079
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Milwaukie Gasoline', intMasterId = 372080
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Milwaukie Diesel', intMasterId = 372081
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Newport Gasoline', intMasterId = 372082
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Newport Diesel', intMasterId = 372083
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Springfield Gasoline', intMasterId = 372084
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Springfield Diesel', intMasterId = 372085
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Tigard Gasoline', intMasterId = 372086
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Tigard Diesel', intMasterId = 372087
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Veneta Gasoline', intMasterId = 372088
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Veneta Diesel', intMasterId = 372089
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Warrenton Gasoline', intMasterId = 372090
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Warrenton Diesel', intMasterId = 372091
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Woodburn Gasoline', intMasterId = 372092
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Woodburn Diesel', intMasterId = 372093
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Multnomah County Gasoline', intMasterId = 372094
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Washington County Gasoline', intMasterId = 372095
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Coburg Diesel', intMasterId = 37116
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Portland City Gasoline', intMasterId = 37117
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Portland City Diesel', intMasterId = 37118
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Reedsport Gasoline', intMasterId = 37119
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Reedsport Diesel', intMasterId = 37120
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Troutdale Gasoline', intMasterId = 37121
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Troutdale Diesel', intMasterId = 37122
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Multnomah County Diesel', intMasterId = 37123
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR - Washington County Diesel', intMasterId = 37124
UNION ALL SELECT intTaxCategoryId = 0, strState = 'OR', strTaxCategory = 'OR Use Fuel Tax (CRD)', intMasterId = 37125

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = 'OR', @TaxCategories = @TaxCategoryOR

DELETE @TaxCategoryOR

GO


PRINT ('Deploying PA Tax Category')

DECLARE @TaxCategoryPA AS TFTaxCategory

INSERT INTO @TaxCategoryPA(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
SELECT intTaxCategoryId = 135, strState = 'PA', strTaxCategory = 'PA Excise Tax Aviation Gasoline', intMasterId = 38135
UNION ALL SELECT intTaxCategoryId = 136, strState = 'PA', strTaxCategory = 'PA Excise Tax Jet Fuel', intMasterId = 38136
UNION ALL SELECT intTaxCategoryId = 137, strState = 'PA', strTaxCategory = 'PA Excise Tax Liquid Fuels (Gasoline and Gasohol)', intMasterId = 38137
UNION ALL SELECT intTaxCategoryId = 138, strState = 'PA', strTaxCategory = 'PA Excise Tax Diesel Clear', intMasterId = 38138
 
EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = 'PA', @TaxCategories = @TaxCategoryPA

DELETE @TaxCategoryPA

GO


PRINT ('Deploying SC Tax Category')

DECLARE @TaxCategorySC AS TFTaxCategory

INSERT INTO @TaxCategorySC(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
SELECT intTaxCategoryId = 133, strState = 'SC', strTaxCategory = 'SC User Fee Gasoline', intMasterId = 40133
UNION ALL SELECT intTaxCategoryId = 134, strState = 'SC', strTaxCategory = 'SC User Fee Diesel Clear', intMasterId = 40134

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = 'SC', @TaxCategories = @TaxCategorySC

DELETE @TaxCategorySC

GO


PRINT ('Deploying TX Tax Category')

DECLARE @TaxCategoryTX AS TFTaxCategory

INSERT INTO @TaxCategoryTX(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
SELECT intTaxCategoryId = 0, strState = 'TX', strTaxCategory = 'TX Excise Tax Diesel', intMasterId = 43129
UNION ALL SELECT intTaxCategoryId = 0, strState = 'TX', strTaxCategory = 'TX Excise Tax Gasoline', intMasterId = 43130
UNION ALL SELECT intTaxCategoryId = 0, strState = 'TX', strTaxCategory = 'TX Excise Tax CNG LNG', intMasterId = 43131

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = 'TX', @TaxCategories = @TaxCategoryTX

DELETE @TaxCategoryTX

GO


PRINT ('Deploying WA Tax Category')

DECLARE @TaxCategoryWA AS TFTaxCategory

INSERT INTO @TaxCategoryWA(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
SELECT intTaxCategoryId = 0, strState = 'WA', strTaxCategory = 'WA Excise Tax Gasoline', intMasterId = 472096
UNION ALL SELECT intTaxCategoryId = 0, strState = 'WA', strTaxCategory = 'WA Excise Tax Diesel Clear', intMasterId = 472097

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = 'WA', @TaxCategories = @TaxCategoryWA

DELETE @TaxCategoryWA

GO

PRINT ('Deploying TN Tax Category')

DECLARE @TaxCategoryTN AS TFTaxCategory

INSERT INTO @TaxCategoryTN(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
SELECT intTaxCategoryId = 0, strState = 'TN', strTaxCategory = 'TN Excise Tax Gasoline', intMasterId = 421
UNION ALL SELECT intTaxCategoryId = 0, strState = 'TN', strTaxCategory = 'TN Excise Tax Diesel Clear', intMasterId = 422
UNION ALL SELECT intTaxCategoryId = 0, strState = 'TN', strTaxCategory = 'TN Excise Tax Diesel Dyed', intMasterId = 423

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = 'TN', @TaxCategories = @TaxCategoryTN

DELETE @TaxCategoryTN

GO