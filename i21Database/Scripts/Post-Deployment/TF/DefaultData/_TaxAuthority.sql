GO
PRINT 'START TF TA'
GO
DECLARE @intTaxAuthorityId INT

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority
IF (@intTaxAuthorityId IS NULL)
BEGIN
	INSERT INTO [tblTFTaxAuthority]
	(
		 [strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA]
	)
	VALUES
	 ('AL','Alabama',				'FALSE',	'FALSE',	'FALSE')
	,('AK','Alaska',				'FALSE',	'FALSE',	'FALSE')
	,('AZ','Arizona',				'FALSE',	'FALSE',	'FALSE')
	,('AR','Arkansas',				'TRUE',		'TRUE',		'FALSE')
	,('CA','California',			'TRUE',		'FALSE',	'FALSE')
	,('CO','Colorado',				'TRUE',		'TRUE',		'FALSE')
	,('CT','Connecticut',			'FALSE',	'FALSE',	'FALSE')
	,('DE','Delaware',				'FALSE',	'FALSE',	'FALSE')
	,('FL','Florida',				'TRUE',		'TRUE',		'FALSE')
	,('GA','Georgia',				'FALSE',	'FALSE',	'FALSE')
	,('HI','Hawaii',				'FALSE',	'FALSE',	'FALSE')
	,('ID','Idaho',					'TRUE',		'TRUE',		'FALSE')
	,('IL','Illinois',				'TRUE',		'TRUE',		'TRUE' )
	,('IN','Indiana',				'TRUE',		'TRUE',		'TRUE' )
	,('IA','Iowa',					'FALSE',	'FALSE',	'TRUE' )
	,('KS','Kansas',				'TRUE',		'TRUE',		'TRUE' )
	,('KY','Kentucky',				'TRUE',		'TRUE',		'TRUE' )
	,('LA','Louisiana',				'FALSE',	'FALSE',	'FALSE')
	,('ME','Maine',					'TRUE',		'FALSE',	'FALSE')
	,('MD','Maryland',				'FALSE',	'FALSE',	'FALSE')
	,('MA','Massachusetts',			'FALSE',	'FALSE',	'FALSE')
	,('MI','Michigan',				'TRUE',		'TRUE',		'FALSE')
	,('MN','Minnesota',				'TRUE',		'TRUE',		'FALSE')
	,('MS','Mississippi',			'TRUE',		'TRUE',		'FALSE')
	,('MO','Missouri',				'TRUE',		'TRUE',		'FALSE')
	,('MT','Montana',				'TRUE',		'TRUE',		'FALSE')
	,('NE','Nebraska',				'TRUE',		'TRUE',		'FALSE')
	,('NV','Nevada',				'FALSE',	'FALSE',	'FALSE')
	,('NH','New Hampshire',			'FALSE',	'FALSE',	'FALSE')
	,('NJ','New Jersey',			'TRUE',		'FALSE',	'FALSE')
	,('NM','New Mexico',			'TRUE',		'TRUE',		'FALSE')
	,('NY','New York',				'TRUE',		'FALSE',	'FALSE')
	,('NC','North Carolina',		'TRUE',		'TRUE',		'FALSE')
	,('ND','North Dakota',			'FALSE',	'FALSE',	'FALSE')
	,('OH','Ohio',					'TRUE',		'TRUE',		'FALSE')
	,('OK','Oklahoma',				'TRUE',		'FALSE',	'FALSE')
	,('OR','Oregon',				'TRUE',		'FALSE',	'FALSE')
	,('PA','Pennsylvania',			'TRUE',		'TRUE',		'FALSE')
	,('RI','Rhode Island',			'FALSE',	'FALSE',	'FALSE')
	,('SC','South Carolina',		'TRUE',		'TRUE',		'FALSE')
	,('SD','South Dakota',			'FALSE',	'FALSE',	'FALSE')
	,('TN','Tennessee',				'TRUE',		'TRUE',		'FALSE')
	,('TX','Texas',					'TRUE',		'TRUE',		'FALSE')
	,('UT','Utah',					'TRUE',		'TRUE',		'FALSE')
	,('VT','Vermont',				'FALSE',	'FALSE',	'FALSE')
	,('VA','Virginia',				'TRUE',		'TRUE',		'FALSE')
	,('WA','Washington',			'TRUE',		'FALSE',	'FALSE')
	,('WV','West Virginia',			'TRUE',		'FALSE',	'FALSE')
	,('WI','Wisconsin',				'FALSE',	'FALSE',	'FALSE')
	,('WY','Wyoming',				'TRUE',		'FALSE',	'FALSE')
	,('US','Federal Government',	'TRUE',		'FALSE',	'FALSE')
END
GO
PRINT 'END TF TA'
GO
