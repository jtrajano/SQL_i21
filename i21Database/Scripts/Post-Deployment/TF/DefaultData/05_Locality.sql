PRINT ('Deploying Locality')
GO

DECLARE @TFLocalityVA AS TFLocality

INSERT INTO @TFLocalityVA(
	intLocalityId
	, strLocalityCode
	, strLocalityZipCode
	, strLocalityName
	, intMasterId
)
SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '22812', strLocalityName = 'Augusta County', intMasterId = 4600001
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '22841', strLocalityName = 'Augusta County', intMasterId = 4600002
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '22843', strLocalityName = 'Augusta County', intMasterId = 4600003
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '22920', strLocalityName = 'Augusta County', intMasterId = 4600004
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '22939', strLocalityName = 'Augusta County', intMasterId = 4600005
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '22952', strLocalityName = 'Augusta County', intMasterId = 4600006
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '22980', strLocalityName = 'Augusta County', intMasterId = 4600007
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24401', strLocalityName = 'Augusta County', intMasterId = 4600008
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24411', strLocalityName = 'Augusta County', intMasterId = 4600009
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24421', strLocalityName = 'Augusta County', intMasterId = 4600010
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24430', strLocalityName = 'Augusta County', intMasterId = 4600011
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24431', strLocalityName = 'Augusta County', intMasterId = 4600012
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24432', strLocalityName = 'Augusta County', intMasterId = 4600013
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24437', strLocalityName = 'Augusta County', intMasterId = 4600014
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24439', strLocalityName = 'Augusta County', intMasterId = 4600015
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24440', strLocalityName = 'Augusta County', intMasterId = 4600016
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24441', strLocalityName = 'Augusta County', intMasterId = 4600017
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24459', strLocalityName = 'Augusta County', intMasterId = 4600018
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24463', strLocalityName = 'Augusta County', intMasterId = 4600019
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24467', strLocalityName = 'Augusta County', intMasterId = 4600020
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24472', strLocalityName = 'Augusta County', intMasterId = 4600021
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24477', strLocalityName = 'Augusta County', intMasterId = 4600022
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24479', strLocalityName = 'Augusta County', intMasterId = 4600023
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24482', strLocalityName = 'Augusta County', intMasterId = 4600024
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24483', strLocalityName = 'Augusta County', intMasterId = 4600025
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24485', strLocalityName = 'Augusta County', intMasterId = 4600026
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24486', strLocalityName = 'Augusta County', intMasterId = 4600027
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51017', strLocalityZipCode = '24412', strLocalityName = 'Bath County', intMasterId = 4600028
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51017', strLocalityZipCode = '24432', strLocalityName = 'Bath County', intMasterId = 4600029
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51017', strLocalityZipCode = '24445', strLocalityName = 'Bath County', intMasterId = 4600030
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51017', strLocalityZipCode = '24460', strLocalityName = 'Bath County', intMasterId = 4600031
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51017', strLocalityZipCode = '24484', strLocalityName = 'Bath County', intMasterId = 4600032
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51017', strLocalityZipCode = '24487', strLocalityName = 'Bath County', intMasterId = 4600033
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51530', strLocalityZipCode = '24416', strLocalityName = 'Buena Vista, City of', intMasterId = 4600034
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51660', strLocalityZipCode = '22801', strLocalityName = 'Harrisonburg, City of', intMasterId = 4600035
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51660', strLocalityZipCode = '22802', strLocalityName = 'Harrisonburg, City of', intMasterId = 4600036
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51660', strLocalityZipCode = '22807', strLocalityName = 'Harrisonburg, City of', intMasterId = 4600037
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51091', strLocalityZipCode = '24413', strLocalityName = 'Highland County', intMasterId = 4600038
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51091', strLocalityZipCode = '24433', strLocalityName = 'Highland County', intMasterId = 4600039
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51091', strLocalityZipCode = '24442', strLocalityName = 'Highland County', intMasterId = 4600040
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51091', strLocalityZipCode = '24458', strLocalityName = 'Highland County', intMasterId = 4600041
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51091', strLocalityZipCode = '24465', strLocalityName = 'Highland County', intMasterId = 4600042
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51091', strLocalityZipCode = '24468', strLocalityName = 'Highland County', intMasterId = 4600043
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51678', strLocalityZipCode = '24450', strLocalityName = 'Lexington, City of', intMasterId = 4600044
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24066', strLocalityName = 'Rockbridge County', intMasterId = 4600045
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24415', strLocalityName = 'Rockbridge County', intMasterId = 4600046
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24416', strLocalityName = 'Rockbridge County', intMasterId = 4600047
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24435', strLocalityName = 'Rockbridge County', intMasterId = 4600048
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24439', strLocalityName = 'Rockbridge County', intMasterId = 4600049
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24450', strLocalityName = 'Rockbridge County', intMasterId = 4600050
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24459', strLocalityName = 'Rockbridge County', intMasterId = 4600051
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24472', strLocalityName = 'Rockbridge County', intMasterId = 4600052
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24473', strLocalityName = 'Rockbridge County', intMasterId = 4600053
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24483', strLocalityName = 'Rockbridge County', intMasterId = 4600054
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24555', strLocalityName = 'Rockbridge County', intMasterId = 4600055
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24578', strLocalityName = 'Rockbridge County', intMasterId = 4600056
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24579', strLocalityName = 'Rockbridge County', intMasterId = 4600057
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22801', strLocalityName = 'Rockingham County', intMasterId = 4600058
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22802', strLocalityName = 'Rockingham County', intMasterId = 4600059
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22811', strLocalityName = 'Rockingham County', intMasterId = 4600060
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22812', strLocalityName = 'Rockingham County', intMasterId = 4600061
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22815', strLocalityName = 'Rockingham County', intMasterId = 4600062
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22820', strLocalityName = 'Rockingham County', intMasterId = 4600063
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22821', strLocalityName = 'Rockingham County', intMasterId = 4600064
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22827', strLocalityName = 'Rockingham County', intMasterId = 4600065
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22830', strLocalityName = 'Rockingham County', intMasterId = 4600066
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22831', strLocalityName = 'Rockingham County', intMasterId = 4600067
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22832', strLocalityName = 'Rockingham County', intMasterId = 4600068
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22833', strLocalityName = 'Rockingham County', intMasterId = 4600069
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22834', strLocalityName = 'Rockingham County', intMasterId = 4600070
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22840', strLocalityName = 'Rockingham County', intMasterId = 4600071
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22841', strLocalityName = 'Rockingham County', intMasterId = 4600072
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22844', strLocalityName = 'Rockingham County', intMasterId = 4600073
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22846', strLocalityName = 'Rockingham County', intMasterId = 4600074
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22848', strLocalityName = 'Rockingham County', intMasterId = 4600075
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22849', strLocalityName = 'Rockingham County', intMasterId = 4600076
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22850', strLocalityName = 'Rockingham County', intMasterId = 4600077
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22853', strLocalityName = 'Rockingham County', intMasterId = 4600078
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '24441', strLocalityName = 'Rockingham County', intMasterId = 4600079
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '24471', strLocalityName = 'Rockingham County', intMasterId = 4600080
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '24486', strLocalityName = 'Rockingham County', intMasterId = 4600081
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51790', strLocalityZipCode = '24401', strLocalityName = 'Staunton, City of', intMasterId = 4600082
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51790', strLocalityZipCode = '24402', strLocalityName = 'Staunton, City of', intMasterId = 4600083
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51790', strLocalityZipCode = '24482', strLocalityName = 'Staunton, City of', intMasterId = 4600084
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51820', strLocalityZipCode = '22952', strLocalityName = 'Waynesboro, City of', intMasterId = 4600085
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51820', strLocalityZipCode = '22980', strLocalityName = 'Waynesboro, City of', intMasterId = 4600086
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51550', strLocalityZipCode = '23320', strLocalityName = 'Chesapeake, City of', intMasterId = 4600087
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51550', strLocalityZipCode = '23321', strLocalityName = 'Chesapeake, City of', intMasterId = 4600088
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51550', strLocalityZipCode = '23322', strLocalityName = 'Chesapeake, City of', intMasterId = 4600089
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51550', strLocalityZipCode = '23323', strLocalityName = 'Chesapeake, City of', intMasterId = 4600090
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51550', strLocalityZipCode = '23324', strLocalityName = 'Chesapeake, City of', intMasterId = 4600091
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51550', strLocalityZipCode = '23325', strLocalityName = 'Chesapeake, City of', intMasterId = 4600092
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51550', strLocalityZipCode = '23326', strLocalityName = 'Chesapeake, City of', intMasterId = 4600093
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51550', strLocalityZipCode = '23464', strLocalityName = 'Chesapeake, City of', intMasterId = 4600094
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51620', strLocalityZipCode = '23851', strLocalityName = 'Franklin, City of', intMasterId = 4600095
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23605', strLocalityName = 'Hampton, City of', intMasterId = 4600096
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23630', strLocalityName = 'Hampton, City of', intMasterId = 4600097
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23651', strLocalityName = 'Hampton, City of', intMasterId = 4600098
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23661', strLocalityName = 'Hampton, City of', intMasterId = 4600099
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23663', strLocalityName = 'Hampton, City of', intMasterId = 4600100
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23664', strLocalityName = 'Hampton, City of', intMasterId = 4600101
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23665', strLocalityName = 'Hampton, City of', intMasterId = 4600102
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23666', strLocalityName = 'Hampton, City of', intMasterId = 4600103
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23667', strLocalityName = 'Hampton, City of', intMasterId = 4600104
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23668', strLocalityName = 'Hampton, City of', intMasterId = 4600105
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23669', strLocalityName = 'Hampton, City of', intMasterId = 4600106
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23681', strLocalityName = 'Hampton, City of', intMasterId = 4600107
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51093', strLocalityZipCode = '23314', strLocalityName = 'Isle of Wight County', intMasterId = 4600108
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51093', strLocalityZipCode = '23315', strLocalityName = 'Isle of Wight County', intMasterId = 4600109
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51093', strLocalityZipCode = '23430', strLocalityName = 'Isle of Wight County', intMasterId = 4600110
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51093', strLocalityZipCode = '23487', strLocalityName = 'Isle of Wight County', intMasterId = 4600111
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51093', strLocalityZipCode = '23851', strLocalityName = 'Isle of Wight County', intMasterId = 4600112
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51093', strLocalityZipCode = '23866', strLocalityName = 'Isle of Wight County', intMasterId = 4600113
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51093', strLocalityZipCode = '23898', strLocalityName = 'Isle of Wight County', intMasterId = 4600114
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51095', strLocalityZipCode = '23011', strLocalityName = 'James City County', intMasterId = 4600115
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51095', strLocalityZipCode = '23089', strLocalityName = 'James City County', intMasterId = 4600116
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51095', strLocalityZipCode = '23168', strLocalityName = 'James City County', intMasterId = 4600117
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51095', strLocalityZipCode = '23185', strLocalityName = 'James City County', intMasterId = 4600118
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51095', strLocalityZipCode = '23188', strLocalityName = 'James City County', intMasterId = 4600119
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51700', strLocalityZipCode = '23601', strLocalityName = 'Newport News, City of', intMasterId = 4600120
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51700', strLocalityZipCode = '23602', strLocalityName = 'Newport News, City of', intMasterId = 4600121
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51700', strLocalityZipCode = '23603', strLocalityName = 'Newport News, City of', intMasterId = 4600122
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51700', strLocalityZipCode = '23604', strLocalityName = 'Newport News, City of', intMasterId = 4600123
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51700', strLocalityZipCode = '23605', strLocalityName = 'Newport News, City of', intMasterId = 4600124
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51700', strLocalityZipCode = '23606', strLocalityName = 'Newport News, City of', intMasterId = 4600125
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51700', strLocalityZipCode = '23607', strLocalityName = 'Newport News, City of', intMasterId = 4600126
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51700', strLocalityZipCode = '23608', strLocalityName = 'Newport News, City of', intMasterId = 4600127
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51700', strLocalityZipCode = '23628', strLocalityName = 'Newport News, City of', intMasterId = 4600128
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23455', strLocalityName = 'Norfolk, City of', intMasterId = 4600129
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23459', strLocalityName = 'Norfolk, City of', intMasterId = 4600130
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23502', strLocalityName = 'Norfolk, City of', intMasterId = 4600131
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23503', strLocalityName = 'Norfolk, City of', intMasterId = 4600132
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23504', strLocalityName = 'Norfolk, City of', intMasterId = 4600133
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23505', strLocalityName = 'Norfolk, City of', intMasterId = 4600134
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23507', strLocalityName = 'Norfolk, City of', intMasterId = 4600135
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23508', strLocalityName = 'Norfolk, City of', intMasterId = 4600136
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23509', strLocalityName = 'Norfolk, City of', intMasterId = 4600137
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23510', strLocalityName = 'Norfolk, City of', intMasterId = 4600138
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23511', strLocalityName = 'Norfolk, City of', intMasterId = 4600139
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23513', strLocalityName = 'Norfolk, City of', intMasterId = 4600140
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23515', strLocalityName = 'Norfolk, City of', intMasterId = 4600141
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23517', strLocalityName = 'Norfolk, City of', intMasterId = 4600142
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23518', strLocalityName = 'Norfolk, City of', intMasterId = 4600143
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23519', strLocalityName = 'Norfolk, City of', intMasterId = 4600144
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23523', strLocalityName = 'Norfolk, City of', intMasterId = 4600145
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23529', strLocalityName = 'Norfolk, City of', intMasterId = 4600146
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23551', strLocalityName = 'Norfolk, City of', intMasterId = 4600147
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51735', strLocalityZipCode = '23662', strLocalityName = 'Poquoson, City of', intMasterId = 4600148
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51740', strLocalityZipCode = '23701', strLocalityName = 'Portsmouth, City of', intMasterId = 4600149
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51740', strLocalityZipCode = '23702', strLocalityName = 'Portsmouth, City of', intMasterId = 4600150
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51740', strLocalityZipCode = '23703', strLocalityName = 'Portsmouth, City of', intMasterId = 4600151
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51740', strLocalityZipCode = '23704', strLocalityName = 'Portsmouth, City of', intMasterId = 4600152
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51740', strLocalityZipCode = '23707', strLocalityName = 'Portsmouth, City of', intMasterId = 4600153
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51740', strLocalityZipCode = '23708', strLocalityName = 'Portsmouth, City of', intMasterId = 4600154
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51740', strLocalityZipCode = '23709', strLocalityName = 'Portsmouth, City of', intMasterId = 4600155
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23827', strLocalityName = 'Southampton County', intMasterId = 4600156
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23828', strLocalityName = 'Southampton County', intMasterId = 4600157
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23829', strLocalityName = 'Southampton County', intMasterId = 4600158
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23837', strLocalityName = 'Southampton County', intMasterId = 4600159
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23844', strLocalityName = 'Southampton County', intMasterId = 4600160
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23847', strLocalityName = 'Southampton County', intMasterId = 4600161
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23851', strLocalityName = 'Southampton County', intMasterId = 4600162
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23866', strLocalityName = 'Southampton County', intMasterId = 4600163
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23874', strLocalityName = 'Southampton County', intMasterId = 4600164
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23878', strLocalityName = 'Southampton County', intMasterId = 4600165
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23888', strLocalityName = 'Southampton County', intMasterId = 4600166
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23898', strLocalityName = 'Southampton County', intMasterId = 4600167
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51800', strLocalityZipCode = '23432', strLocalityName = 'Suffolk, City of', intMasterId = 4600168
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51800', strLocalityZipCode = '23433', strLocalityName = 'Suffolk, City of', intMasterId = 4600169
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51800', strLocalityZipCode = '23434', strLocalityName = 'Suffolk, City of', intMasterId = 4600170
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51800', strLocalityZipCode = '23435', strLocalityName = 'Suffolk, City of', intMasterId = 4600171
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51800', strLocalityZipCode = '23436', strLocalityName = 'Suffolk, City of', intMasterId = 4600172
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51800', strLocalityZipCode = '23437', strLocalityName = 'Suffolk, City of', intMasterId = 4600173
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51800', strLocalityZipCode = '23438', strLocalityName = 'Suffolk, City of', intMasterId = 4600174
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23451', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600175
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23452', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600176
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23453', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600177
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23454', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600178
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23455', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600179
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23456', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600180
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23457', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600181
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23459', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600182
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23460', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600183
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23461', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600184
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23462', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600185
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23463', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600186
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23464', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600187
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23465', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600188
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23479', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600189
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51830', strLocalityZipCode = '23185', strLocalityName = 'Williamsburg, City of', intMasterId = 4600190
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51830', strLocalityZipCode = '23186', strLocalityName = 'Williamsburg, City of', intMasterId = 4600191
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51830', strLocalityZipCode = '23188', strLocalityName = 'Williamsburg, City of', intMasterId = 4600192
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51199', strLocalityZipCode = '23185', strLocalityName = 'York County', intMasterId = 4600193
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51199', strLocalityZipCode = '23188', strLocalityName = 'York County', intMasterId = 4600194
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51199', strLocalityZipCode = '23603', strLocalityName = 'York County', intMasterId = 4600195
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51199', strLocalityZipCode = '23665', strLocalityName = 'York County', intMasterId = 4600196
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51199', strLocalityZipCode = '23690', strLocalityName = 'York County', intMasterId = 4600197
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51199', strLocalityZipCode = '23691', strLocalityName = 'York County', intMasterId = 4600198
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51199', strLocalityZipCode = '23692', strLocalityName = 'York County', intMasterId = 4600199
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51199', strLocalityZipCode = '23693', strLocalityName = 'York County', intMasterId = 4600200
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51199', strLocalityZipCode = '23696', strLocalityName = 'York County', intMasterId = 4600201
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51021', strLocalityZipCode = '24084', strLocalityName = 'Bland County', intMasterId = 4600202
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51021', strLocalityZipCode = '24124', strLocalityName = 'Bland County', intMasterId = 4600203
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51021', strLocalityZipCode = '24134', strLocalityName = 'Bland County', intMasterId = 4600204
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51021', strLocalityZipCode = '24314', strLocalityName = 'Bland County', intMasterId = 4600205
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51021', strLocalityZipCode = '24315', strLocalityName = 'Bland County', intMasterId = 4600206
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51021', strLocalityZipCode = '24318', strLocalityName = 'Bland County', intMasterId = 4600207
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51021', strLocalityZipCode = '24366', strLocalityName = 'Bland County', intMasterId = 4600208
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51520', strLocalityZipCode = '24201', strLocalityName = 'Bristol, City of', intMasterId = 4600209
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51520', strLocalityZipCode = '24202', strLocalityName = 'Bristol, City of', intMasterId = 4600210
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24105', strLocalityName = 'Carroll County', intMasterId = 4600211
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24120', strLocalityName = 'Carroll County', intMasterId = 4600212
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24312', strLocalityName = 'Carroll County', intMasterId = 4600213
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24317', strLocalityName = 'Carroll County', intMasterId = 4600214
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24325', strLocalityName = 'Carroll County', intMasterId = 4600215
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24328', strLocalityName = 'Carroll County', intMasterId = 4600216
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24330', strLocalityName = 'Carroll County', intMasterId = 4600217
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24333', strLocalityName = 'Carroll County', intMasterId = 4600218
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24343', strLocalityName = 'Carroll County', intMasterId = 4600219
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24347', strLocalityName = 'Carroll County', intMasterId = 4600220
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24350', strLocalityName = 'Carroll County', intMasterId = 4600221
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24351', strLocalityName = 'Carroll County', intMasterId = 4600222
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24352', strLocalityName = 'Carroll County', intMasterId = 4600223
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24380', strLocalityName = 'Carroll County', intMasterId = 4600224
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24381', strLocalityName = 'Carroll County', intMasterId = 4600225
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51640', strLocalityZipCode = '24333', strLocalityName = 'Galax, City of', intMasterId = 4600226
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51077', strLocalityZipCode = '24292', strLocalityName = 'Grayson County', intMasterId = 4600227
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51077', strLocalityZipCode = '24326', strLocalityName = 'Grayson County', intMasterId = 4600228
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51077', strLocalityZipCode = '24330', strLocalityName = 'Grayson County', intMasterId = 4600229
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51077', strLocalityZipCode = '24333', strLocalityName = 'Grayson County', intMasterId = 4600230
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51077', strLocalityZipCode = '24348', strLocalityName = 'Grayson County', intMasterId = 4600231
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51077', strLocalityZipCode = '24350', strLocalityName = 'Grayson County', intMasterId = 4600232
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51077', strLocalityZipCode = '24363', strLocalityName = 'Grayson County', intMasterId = 4600233
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51077', strLocalityZipCode = '24378', strLocalityName = 'Grayson County', intMasterId = 4600234
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51173', strLocalityZipCode = '24236', strLocalityName = 'Smyth County', intMasterId = 4600235
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51173', strLocalityZipCode = '24311', strLocalityName = 'Smyth County', intMasterId = 4600236
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51173', strLocalityZipCode = '24318', strLocalityName = 'Smyth County', intMasterId = 4600237
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51173', strLocalityZipCode = '24319', strLocalityName = 'Smyth County', intMasterId = 4600238
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51173', strLocalityZipCode = '24354', strLocalityName = 'Smyth County', intMasterId = 4600239
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51173', strLocalityZipCode = '24368', strLocalityName = 'Smyth County', intMasterId = 4600240
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51173', strLocalityZipCode = '24370', strLocalityName = 'Smyth County', intMasterId = 4600241
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51173', strLocalityZipCode = '24374', strLocalityName = 'Smyth County', intMasterId = 4600242
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51173', strLocalityZipCode = '24375', strLocalityName = 'Smyth County', intMasterId = 4600243
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51173', strLocalityZipCode = '24378', strLocalityName = 'Smyth County', intMasterId = 4600244
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51191', strLocalityZipCode = '24202', strLocalityName = 'Washington County', intMasterId = 4600245
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51191', strLocalityZipCode = '24210', strLocalityName = 'Washington County', intMasterId = 4600246
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51191', strLocalityZipCode = '24211', strLocalityName = 'Washington County', intMasterId = 4600247
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51191', strLocalityZipCode = '24236', strLocalityName = 'Washington County', intMasterId = 4600248
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51191', strLocalityZipCode = '24270', strLocalityName = 'Washington County', intMasterId = 4600249
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51191', strLocalityZipCode = '24319', strLocalityName = 'Washington County', intMasterId = 4600250
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51191', strLocalityZipCode = '24340', strLocalityName = 'Washington County', intMasterId = 4600251
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51191', strLocalityZipCode = '24361', strLocalityName = 'Washington County', intMasterId = 4600252
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51191', strLocalityZipCode = '24370', strLocalityName = 'Washington County', intMasterId = 4600253
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51197', strLocalityZipCode = '24311', strLocalityName = 'Wythe County', intMasterId = 4600254
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51197', strLocalityZipCode = '24312', strLocalityName = 'Wythe County', intMasterId = 4600255
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51197', strLocalityZipCode = '24313', strLocalityName = 'Wythe County', intMasterId = 4600256
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51197', strLocalityZipCode = '24322', strLocalityName = 'Wythe County', intMasterId = 4600257
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51197', strLocalityZipCode = '24323', strLocalityName = 'Wythe County', intMasterId = 4600258
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51197', strLocalityZipCode = '24324', strLocalityName = 'Wythe County', intMasterId = 4600259
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51197', strLocalityZipCode = '24350', strLocalityName = 'Wythe County', intMasterId = 4600260
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51197', strLocalityZipCode = '24360', strLocalityName = 'Wythe County', intMasterId = 4600261
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51197', strLocalityZipCode = '24368', strLocalityName = 'Wythe County', intMasterId = 4600262
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51197', strLocalityZipCode = '24374', strLocalityName = 'Wythe County', intMasterId = 4600263
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51197', strLocalityZipCode = '24382', strLocalityName = 'Wythe County', intMasterId = 4600264
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51063', strLocalityZipCode = '24072', strLocalityName = 'Floyd County', intMasterId = 4600265
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51063', strLocalityZipCode = '24079', strLocalityName = 'Floyd County', intMasterId = 4600266
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51063', strLocalityZipCode = '24091', strLocalityName = 'Floyd County', intMasterId = 4600267
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51063', strLocalityZipCode = '24105', strLocalityName = 'Floyd County', intMasterId = 4600268
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51063', strLocalityZipCode = '24120', strLocalityName = 'Floyd County', intMasterId = 4600269
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51063', strLocalityZipCode = '24138', strLocalityName = 'Floyd County', intMasterId = 4600270
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51063', strLocalityZipCode = '24141', strLocalityName = 'Floyd County', intMasterId = 4600271
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51063', strLocalityZipCode = '24149', strLocalityName = 'Floyd County', intMasterId = 4600272
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51063', strLocalityZipCode = '24162', strLocalityName = 'Floyd County', intMasterId = 4600273
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51063', strLocalityZipCode = '24380', strLocalityName = 'Floyd County', intMasterId = 4600274
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51071', strLocalityZipCode = '24086', strLocalityName = 'Giles County', intMasterId = 4600275
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51071', strLocalityZipCode = '24093', strLocalityName = 'Giles County', intMasterId = 4600276
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51071', strLocalityZipCode = '24124', strLocalityName = 'Giles County', intMasterId = 4600277
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51071', strLocalityZipCode = '24128', strLocalityName = 'Giles County', intMasterId = 4600278
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51071', strLocalityZipCode = '24134', strLocalityName = 'Giles County', intMasterId = 4600279
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51071', strLocalityZipCode = '24136', strLocalityName = 'Giles County', intMasterId = 4600280
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51071', strLocalityZipCode = '24147', strLocalityName = 'Giles County', intMasterId = 4600281
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51071', strLocalityZipCode = '24150', strLocalityName = 'Giles County', intMasterId = 4600282
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51071', strLocalityZipCode = '24167', strLocalityName = 'Giles County', intMasterId = 4600283
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51071', strLocalityZipCode = '24315', strLocalityName = 'Giles County', intMasterId = 4600284
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24059', strLocalityName = 'Montgomery County', intMasterId = 4600285
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24060', strLocalityName = 'Montgomery County', intMasterId = 4600286
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24061', strLocalityName = 'Montgomery County', intMasterId = 4600287
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24070', strLocalityName = 'Montgomery County', intMasterId = 4600288
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24073', strLocalityName = 'Montgomery County', intMasterId = 4600289
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24087', strLocalityName = 'Montgomery County', intMasterId = 4600290
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24128', strLocalityName = 'Montgomery County', intMasterId = 4600291
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24138', strLocalityName = 'Montgomery County', intMasterId = 4600292
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24141', strLocalityName = 'Montgomery County', intMasterId = 4600293
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24149', strLocalityName = 'Montgomery County', intMasterId = 4600294
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24162', strLocalityName = 'Montgomery County', intMasterId = 4600295
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24347', strLocalityName = 'Montgomery County', intMasterId = 4600296
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51155', strLocalityZipCode = '24058', strLocalityName = 'Pulaski County', intMasterId = 4600297
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51155', strLocalityZipCode = '24084', strLocalityName = 'Pulaski County', intMasterId = 4600298
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51155', strLocalityZipCode = '24126', strLocalityName = 'Pulaski County', intMasterId = 4600299
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51155', strLocalityZipCode = '24129', strLocalityName = 'Pulaski County', intMasterId = 4600300
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51155', strLocalityZipCode = '24132', strLocalityName = 'Pulaski County', intMasterId = 4600301
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51155', strLocalityZipCode = '24141', strLocalityName = 'Pulaski County', intMasterId = 4600302
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51155', strLocalityZipCode = '24301', strLocalityName = 'Pulaski County', intMasterId = 4600303
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51155', strLocalityZipCode = '24324', strLocalityName = 'Pulaski County', intMasterId = 4600304
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51155', strLocalityZipCode = '24347', strLocalityName = 'Pulaski County', intMasterId = 4600305
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51750', strLocalityZipCode = '24141', strLocalityName = 'Radford, City of', intMasterId = 4600306
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51750', strLocalityZipCode = '24142', strLocalityName = 'Radford, City of', intMasterId = 4600307
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51043', strLocalityZipCode = '20130', strLocalityName = 'Clarke County', intMasterId = 4600308
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51043', strLocalityZipCode = '20135', strLocalityName = 'Clarke County', intMasterId = 4600309
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51043', strLocalityZipCode = '22611', strLocalityName = 'Clarke County', intMasterId = 4600310
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51043', strLocalityZipCode = '22620', strLocalityName = 'Clarke County', intMasterId = 4600311
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51043', strLocalityZipCode = '22646', strLocalityName = 'Clarke County', intMasterId = 4600312
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51043', strLocalityZipCode = '22663', strLocalityName = 'Clarke County', intMasterId = 4600313
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51069', strLocalityZipCode = '22602', strLocalityName = 'Frederick County', intMasterId = 4600314
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51069', strLocalityZipCode = '22603', strLocalityName = 'Frederick County', intMasterId = 4600315
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51069', strLocalityZipCode = '22622', strLocalityName = 'Frederick County', intMasterId = 4600316
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51069', strLocalityZipCode = '22624', strLocalityName = 'Frederick County', intMasterId = 4600317
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51069', strLocalityZipCode = '22625', strLocalityName = 'Frederick County', intMasterId = 4600318
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51069', strLocalityZipCode = '22637', strLocalityName = 'Frederick County', intMasterId = 4600319
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51069', strLocalityZipCode = '22645', strLocalityName = 'Frederick County', intMasterId = 4600320
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51069', strLocalityZipCode = '22654', strLocalityName = 'Frederick County', intMasterId = 4600321
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51069', strLocalityZipCode = '22655', strLocalityName = 'Frederick County', intMasterId = 4600322
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51069', strLocalityZipCode = '22656', strLocalityName = 'Frederick County', intMasterId = 4600323
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51139', strLocalityZipCode = '22610', strLocalityName = 'Page County', intMasterId = 4600324
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51139', strLocalityZipCode = '22650', strLocalityName = 'Page County', intMasterId = 4600325
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51139', strLocalityZipCode = '22743', strLocalityName = 'Page County', intMasterId = 4600326
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51139', strLocalityZipCode = '22815', strLocalityName = 'Page County', intMasterId = 4600327
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51139', strLocalityZipCode = '22827', strLocalityName = 'Page County', intMasterId = 4600328
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51139', strLocalityZipCode = '22835', strLocalityName = 'Page County', intMasterId = 4600329
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51139', strLocalityZipCode = '22849', strLocalityName = 'Page County', intMasterId = 4600330
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51139', strLocalityZipCode = '22851', strLocalityName = 'Page County', intMasterId = 4600331
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22626', strLocalityName = 'Shenandoah County', intMasterId = 4600332
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22641', strLocalityName = 'Shenandoah County', intMasterId = 4600333
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22644', strLocalityName = 'Shenandoah County', intMasterId = 4600334
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22645', strLocalityName = 'Shenandoah County', intMasterId = 4600335
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22652', strLocalityName = 'Shenandoah County', intMasterId = 4600336
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22654', strLocalityName = 'Shenandoah County', intMasterId = 4600337
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22657', strLocalityName = 'Shenandoah County', intMasterId = 4600338
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22660', strLocalityName = 'Shenandoah County', intMasterId = 4600339
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22664', strLocalityName = 'Shenandoah County', intMasterId = 4600340
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22810', strLocalityName = 'Shenandoah County', intMasterId = 4600341
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22815', strLocalityName = 'Shenandoah County', intMasterId = 4600342
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22824', strLocalityName = 'Shenandoah County', intMasterId = 4600343
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22842', strLocalityName = 'Shenandoah County', intMasterId = 4600344
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22844', strLocalityName = 'Shenandoah County', intMasterId = 4600345
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22845', strLocalityName = 'Shenandoah County', intMasterId = 4600346
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22847', strLocalityName = 'Shenandoah County', intMasterId = 4600347
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22849', strLocalityName = 'Shenandoah County', intMasterId = 4600348
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22853', strLocalityName = 'Shenandoah County', intMasterId = 4600349
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51187', strLocalityZipCode = '22610', strLocalityName = 'Warren County', intMasterId = 4600350
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51187', strLocalityZipCode = '22630', strLocalityName = 'Warren County', intMasterId = 4600351
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51187', strLocalityZipCode = '22642', strLocalityName = 'Warren County', intMasterId = 4600352
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51187', strLocalityZipCode = '22649', strLocalityName = 'Warren County', intMasterId = 4600353
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51840', strLocalityZipCode = '22601', strLocalityName = 'Winchester, City of', intMasterId = 4600354
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51840', strLocalityZipCode = '22602', strLocalityName = 'Winchester, City of', intMasterId = 4600355
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51840', strLocalityZipCode = '22603', strLocalityName = 'Winchester, City of', intMasterId = 4600356
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51510', strLocalityZipCode = '22206', strLocalityName = 'Alexandria, City of', intMasterId = 4600357
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51510', strLocalityZipCode = '22301', strLocalityName = 'Alexandria, City of', intMasterId = 4600358
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51510', strLocalityZipCode = '22302', strLocalityName = 'Alexandria, City of', intMasterId = 4600359
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51510', strLocalityZipCode = '22304', strLocalityName = 'Alexandria, City of', intMasterId = 4600360
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51510', strLocalityZipCode = '22305', strLocalityName = 'Alexandria, City of', intMasterId = 4600361
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51510', strLocalityZipCode = '22311', strLocalityName = 'Alexandria, City of', intMasterId = 4600362
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51510', strLocalityZipCode = '22312', strLocalityName = 'Alexandria, City of', intMasterId = 4600363
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51510', strLocalityZipCode = '22314', strLocalityName = 'Alexandria, City of', intMasterId = 4600364
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51013', strLocalityZipCode = '22101', strLocalityName = 'Arlington County', intMasterId = 4600365
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51013', strLocalityZipCode = '22201', strLocalityName = 'Arlington County', intMasterId = 4600366
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51013', strLocalityZipCode = '22202', strLocalityName = 'Arlington County', intMasterId = 4600367
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51013', strLocalityZipCode = '22203', strLocalityName = 'Arlington County', intMasterId = 4600368
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51013', strLocalityZipCode = '22204', strLocalityName = 'Arlington County', intMasterId = 4600369
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51013', strLocalityZipCode = '22205', strLocalityName = 'Arlington County', intMasterId = 4600370
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51013', strLocalityZipCode = '22206', strLocalityName = 'Arlington County', intMasterId = 4600371
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51013', strLocalityZipCode = '22207', strLocalityName = 'Arlington County', intMasterId = 4600372
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51013', strLocalityZipCode = '22209', strLocalityName = 'Arlington County', intMasterId = 4600373
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51013', strLocalityZipCode = '22211', strLocalityName = 'Arlington County', intMasterId = 4600374
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51013', strLocalityZipCode = '22213', strLocalityName = 'Arlington County', intMasterId = 4600375
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '20120', strLocalityName = 'Fairfax County', intMasterId = 4600376
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '20121', strLocalityName = 'Fairfax County', intMasterId = 4600377
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '20124', strLocalityName = 'Fairfax County', intMasterId = 4600378
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '20151', strLocalityName = 'Fairfax County', intMasterId = 4600379
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '20166', strLocalityName = 'Fairfax County', intMasterId = 4600380
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '20170', strLocalityName = 'Fairfax County', intMasterId = 4600381
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '20171', strLocalityName = 'Fairfax County', intMasterId = 4600382
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '20190', strLocalityName = 'Fairfax County', intMasterId = 4600383
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '20191', strLocalityName = 'Fairfax County', intMasterId = 4600384
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '20194', strLocalityName = 'Fairfax County', intMasterId = 4600385
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22003', strLocalityName = 'Fairfax County', intMasterId = 4600386
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22015', strLocalityName = 'Fairfax County', intMasterId = 4600387
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22027', strLocalityName = 'Fairfax County', intMasterId = 4600388
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22030', strLocalityName = 'Fairfax County', intMasterId = 4600389
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22031', strLocalityName = 'Fairfax County', intMasterId = 4600390
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22032', strLocalityName = 'Fairfax County', intMasterId = 4600391
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22033', strLocalityName = 'Fairfax County', intMasterId = 4600392
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22039', strLocalityName = 'Fairfax County', intMasterId = 4600393
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22041', strLocalityName = 'Fairfax County', intMasterId = 4600394
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22042', strLocalityName = 'Fairfax County', intMasterId = 4600395
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22043', strLocalityName = 'Fairfax County', intMasterId = 4600396
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22044', strLocalityName = 'Fairfax County', intMasterId = 4600397
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22046', strLocalityName = 'Fairfax County', intMasterId = 4600398
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22060', strLocalityName = 'Fairfax County', intMasterId = 4600399
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22066', strLocalityName = 'Fairfax County', intMasterId = 4600400
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22079', strLocalityName = 'Fairfax County', intMasterId = 4600401
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22101', strLocalityName = 'Fairfax County', intMasterId = 4600402
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22102', strLocalityName = 'Fairfax County', intMasterId = 4600403
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22124', strLocalityName = 'Fairfax County', intMasterId = 4600404
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22150', strLocalityName = 'Fairfax County', intMasterId = 4600405
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22151', strLocalityName = 'Fairfax County', intMasterId = 4600406
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22152', strLocalityName = 'Fairfax County', intMasterId = 4600407
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22153', strLocalityName = 'Fairfax County', intMasterId = 4600408
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22180', strLocalityName = 'Fairfax County', intMasterId = 4600409
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22181', strLocalityName = 'Fairfax County', intMasterId = 4600410
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22182', strLocalityName = 'Fairfax County', intMasterId = 4600411
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22207', strLocalityName = 'Fairfax County', intMasterId = 4600412
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22303', strLocalityName = 'Fairfax County', intMasterId = 4600413
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22304', strLocalityName = 'Fairfax County', intMasterId = 4600414
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22306', strLocalityName = 'Fairfax County', intMasterId = 4600415
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22307', strLocalityName = 'Fairfax County', intMasterId = 4600416
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22308', strLocalityName = 'Fairfax County', intMasterId = 4600417
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22309', strLocalityName = 'Fairfax County', intMasterId = 4600418
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22310', strLocalityName = 'Fairfax County', intMasterId = 4600419
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22311', strLocalityName = 'Fairfax County', intMasterId = 4600420
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22312', strLocalityName = 'Fairfax County', intMasterId = 4600421
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22315', strLocalityName = 'Fairfax County', intMasterId = 4600422
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51600', strLocalityZipCode = '22030', strLocalityName = 'Fairfax, City of', intMasterId = 4600423
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51600', strLocalityZipCode = '22031', strLocalityName = 'Fairfax, City of', intMasterId = 4600424
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51600', strLocalityZipCode = '22032', strLocalityName = 'Fairfax, City of', intMasterId = 4600425
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51610', strLocalityZipCode = '22042', strLocalityName = 'Falls Church, City of', intMasterId = 4600426
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51610', strLocalityZipCode = '22044', strLocalityName = 'Falls Church, City of', intMasterId = 4600427
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51610', strLocalityZipCode = '22046', strLocalityName = 'Falls Church, City of', intMasterId = 4600428
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20105', strLocalityName = 'Loudoun County', intMasterId = 4600429
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20120', strLocalityName = 'Loudoun County', intMasterId = 4600430
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20129', strLocalityName = 'Loudoun County', intMasterId = 4600431
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20132', strLocalityName = 'Loudoun County', intMasterId = 4600432
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20141', strLocalityName = 'Loudoun County', intMasterId = 4600433
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20147', strLocalityName = 'Loudoun County', intMasterId = 4600434
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20148', strLocalityName = 'Loudoun County', intMasterId = 4600435
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20152', strLocalityName = 'Loudoun County', intMasterId = 4600436
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20158', strLocalityName = 'Loudoun County', intMasterId = 4600437
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20164', strLocalityName = 'Loudoun County', intMasterId = 4600438
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20165', strLocalityName = 'Loudoun County', intMasterId = 4600439
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20166', strLocalityName = 'Loudoun County', intMasterId = 4600440
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20175', strLocalityName = 'Loudoun County', intMasterId = 4600441
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20176', strLocalityName = 'Loudoun County', intMasterId = 4600442
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20180', strLocalityName = 'Loudoun County', intMasterId = 4600443
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20197', strLocalityName = 'Loudoun County', intMasterId = 4600444
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '22066', strLocalityName = 'Loudoun County', intMasterId = 4600445
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51630', strLocalityZipCode = '22401', strLocalityName = 'Fredericksburg, City of', intMasterId = 4600446
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51685', strLocalityZipCode = '20110', strLocalityName = 'Manassas Park, City of', intMasterId = 4600447
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51685', strLocalityZipCode = '20111', strLocalityName = 'Manassas Park, City of', intMasterId = 4600448
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51683', strLocalityZipCode = '20110', strLocalityName = 'Manassas, City of', intMasterId = 4600449
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '20109', strLocalityName = 'Prince William County', intMasterId = 4600450
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '20110', strLocalityName = 'Prince William County', intMasterId = 4600451
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '20111', strLocalityName = 'Prince William County', intMasterId = 4600452
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '20112', strLocalityName = 'Prince William County', intMasterId = 4600453
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '20136', strLocalityName = 'Prince William County', intMasterId = 4600454
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '20143', strLocalityName = 'Prince William County', intMasterId = 4600455
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '20155', strLocalityName = 'Prince William County', intMasterId = 4600456
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '20169', strLocalityName = 'Prince William County', intMasterId = 4600457
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '20181', strLocalityName = 'Prince William County', intMasterId = 4600458
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '20182', strLocalityName = 'Prince William County', intMasterId = 4600459
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '22026', strLocalityName = 'Prince William County', intMasterId = 4600460
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '22134', strLocalityName = 'Prince William County', intMasterId = 4600461
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '22135', strLocalityName = 'Prince William County', intMasterId = 4600462
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '22172', strLocalityName = 'Prince William County', intMasterId = 4600463
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '22191', strLocalityName = 'Prince William County', intMasterId = 4600464
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '22192', strLocalityName = 'Prince William County', intMasterId = 4600465
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '22193', strLocalityName = 'Prince William County', intMasterId = 4600466
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51177', strLocalityZipCode = '22407', strLocalityName = 'Spotsylvania County', intMasterId = 4600467
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51177', strLocalityZipCode = '22408', strLocalityName = 'Spotsylvania County', intMasterId = 4600468
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51177', strLocalityZipCode = '22534', strLocalityName = 'Spotsylvania County', intMasterId = 4600469
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51177', strLocalityZipCode = '22551', strLocalityName = 'Spotsylvania County', intMasterId = 4600470
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51177', strLocalityZipCode = '22553', strLocalityName = 'Spotsylvania County', intMasterId = 4600471
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51177', strLocalityZipCode = '22580', strLocalityName = 'Spotsylvania County', intMasterId = 4600472
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51177', strLocalityZipCode = '22960', strLocalityName = 'Spotsylvania County', intMasterId = 4600473
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51177', strLocalityZipCode = '23024', strLocalityName = 'Spotsylvania County', intMasterId = 4600474
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51177', strLocalityZipCode = '23117', strLocalityName = 'Spotsylvania County', intMasterId = 4600475
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51179', strLocalityZipCode = '22135', strLocalityName = 'Stafford County', intMasterId = 4600476
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51179', strLocalityZipCode = '22405', strLocalityName = 'Stafford County', intMasterId = 4600477
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51179', strLocalityZipCode = '22406', strLocalityName = 'Stafford County', intMasterId = 4600478
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51179', strLocalityZipCode = '22412', strLocalityName = 'Stafford County', intMasterId = 4600479
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51179', strLocalityZipCode = '22554', strLocalityName = 'Stafford County', intMasterId = 4600480
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51179', strLocalityZipCode = '22556', strLocalityName = 'Stafford County', intMasterId = 4600481
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51005', strLocalityZipCode = '24422', strLocalityName = 'Alleghany County', intMasterId = 4600482
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51005', strLocalityZipCode = '24426', strLocalityName = 'Alleghany County', intMasterId = 4600483
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51005', strLocalityZipCode = '24445', strLocalityName = 'Alleghany County', intMasterId = 4600484
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51005', strLocalityZipCode = '24448', strLocalityName = 'Alleghany County', intMasterId = 4600485
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51005', strLocalityZipCode = '24457', strLocalityName = 'Alleghany County', intMasterId = 4600486
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51005', strLocalityZipCode = '24474', strLocalityName = 'Alleghany County', intMasterId = 4600487
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24012', strLocalityName = 'Botetourt County', intMasterId = 4600488
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24019', strLocalityName = 'Botetourt County', intMasterId = 4600489
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24050', strLocalityName = 'Botetourt County', intMasterId = 4600490
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24064', strLocalityName = 'Botetourt County', intMasterId = 4600491
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24066', strLocalityName = 'Botetourt County', intMasterId = 4600492
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24077', strLocalityName = 'Botetourt County', intMasterId = 4600493
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24083', strLocalityName = 'Botetourt County', intMasterId = 4600494
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24085', strLocalityName = 'Botetourt County', intMasterId = 4600495
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24090', strLocalityName = 'Botetourt County', intMasterId = 4600496
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24130', strLocalityName = 'Botetourt County', intMasterId = 4600497
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24153', strLocalityName = 'Botetourt County', intMasterId = 4600498
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24175', strLocalityName = 'Botetourt County', intMasterId = 4600499
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24438', strLocalityName = 'Botetourt County', intMasterId = 4600500
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24579', strLocalityName = 'Botetourt County', intMasterId = 4600501
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51580', strLocalityZipCode = '24426', strLocalityName = 'Covington, City of', intMasterId = 4600502
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51045', strLocalityZipCode = '24070', strLocalityName = 'Craig County', intMasterId = 4600503
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51045', strLocalityZipCode = '24127', strLocalityName = 'Craig County', intMasterId = 4600504
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51045', strLocalityZipCode = '24128', strLocalityName = 'Craig County', intMasterId = 4600505
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51045', strLocalityZipCode = '24131', strLocalityName = 'Craig County', intMasterId = 4600506
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24055', strLocalityName = 'Franklin County', intMasterId = 4600507
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24059', strLocalityName = 'Franklin County', intMasterId = 4600508
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24065', strLocalityName = 'Franklin County', intMasterId = 4600509
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24067', strLocalityName = 'Franklin County', intMasterId = 4600510
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24088', strLocalityName = 'Franklin County', intMasterId = 4600511
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24091', strLocalityName = 'Franklin County', intMasterId = 4600512
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24092', strLocalityName = 'Franklin County', intMasterId = 4600513
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24101', strLocalityName = 'Franklin County', intMasterId = 4600514
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24102', strLocalityName = 'Franklin County', intMasterId = 4600515
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24112', strLocalityName = 'Franklin County', intMasterId = 4600516
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24121', strLocalityName = 'Franklin County', intMasterId = 4600517
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24137', strLocalityName = 'Franklin County', intMasterId = 4600518
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24146', strLocalityName = 'Franklin County', intMasterId = 4600519
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24151', strLocalityName = 'Franklin County', intMasterId = 4600520
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24176', strLocalityName = 'Franklin County', intMasterId = 4600521
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24184', strLocalityName = 'Franklin County', intMasterId = 4600522
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24012', strLocalityName = 'Roanoke County', intMasterId = 4600523
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24014', strLocalityName = 'Roanoke County', intMasterId = 4600524
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24018', strLocalityName = 'Roanoke County', intMasterId = 4600525
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24019', strLocalityName = 'Roanoke County', intMasterId = 4600526
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24020', strLocalityName = 'Roanoke County', intMasterId = 4600527
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24059', strLocalityName = 'Roanoke County', intMasterId = 4600528
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24065', strLocalityName = 'Roanoke County', intMasterId = 4600529
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24070', strLocalityName = 'Roanoke County', intMasterId = 4600530
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24087', strLocalityName = 'Roanoke County', intMasterId = 4600531
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24153', strLocalityName = 'Roanoke County', intMasterId = 4600532
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24175', strLocalityName = 'Roanoke County', intMasterId = 4600533
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24179', strLocalityName = 'Roanoke County', intMasterId = 4600534
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24011', strLocalityName = 'Roanoke, City of', intMasterId = 4600535
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24012', strLocalityName = 'Roanoke, City of', intMasterId = 4600536
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24013', strLocalityName = 'Roanoke, City of', intMasterId = 4600537
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24014', strLocalityName = 'Roanoke, City of', intMasterId = 4600538
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24015', strLocalityName = 'Roanoke, City of', intMasterId = 4600539
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24016', strLocalityName = 'Roanoke, City of', intMasterId = 4600540
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24017', strLocalityName = 'Roanoke, City of', intMasterId = 4600541
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24018', strLocalityName = 'Roanoke, City of', intMasterId = 4600542
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24019', strLocalityName = 'Roanoke, City of', intMasterId = 4600543
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24020', strLocalityName = 'Roanoke, City of', intMasterId = 4600544
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24050', strLocalityName = 'Roanoke, City of', intMasterId = 4600545
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24155', strLocalityName = 'Roanoke, City of', intMasterId = 4600546
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24157', strLocalityName = 'Roanoke, City of', intMasterId = 4600547
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51775', strLocalityZipCode = '24153', strLocalityName = 'Salem, City of', intMasterId = 4600548
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51775', strLocalityZipCode = '24155', strLocalityName = 'Salem, City of', intMasterId = 4600549
UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51775', strLocalityZipCode = '24157', strLocalityName = 'Salem, City of', intMasterId = 4600550

EXEC uspTFUpgradeLocality @TaxAuthorityCode = 'VA', @Locality = @TFLocalityVA

DELETE @TFLocalityVA
GO
