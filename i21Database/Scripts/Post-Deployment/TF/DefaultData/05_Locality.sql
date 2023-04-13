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
------SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '22812', strLocalityName = 'Augusta County', intMasterId = 4600001
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '22841', strLocalityName = 'Augusta County', intMasterId = 4600002
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '22843', strLocalityName = 'Augusta County', intMasterId = 4600003
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '22920', strLocalityName = 'Augusta County', intMasterId = 4600004
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '22939', strLocalityName = 'Augusta County', intMasterId = 4600005
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '22952', strLocalityName = 'Augusta County', intMasterId = 4600006
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '22980', strLocalityName = 'Augusta County', intMasterId = 4600007
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24401', strLocalityName = 'Augusta County', intMasterId = 4600008
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24411', strLocalityName = 'Augusta County', intMasterId = 4600009
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24421', strLocalityName = 'Augusta County', intMasterId = 4600010
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24430', strLocalityName = 'Augusta County', intMasterId = 4600011
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24431', strLocalityName = 'Augusta County', intMasterId = 4600012
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24432', strLocalityName = 'Augusta County', intMasterId = 4600013
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24437', strLocalityName = 'Augusta County', intMasterId = 4600014
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24439', strLocalityName = 'Augusta County', intMasterId = 4600015
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24440', strLocalityName = 'Augusta County', intMasterId = 4600016
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24441', strLocalityName = 'Augusta County', intMasterId = 4600017
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24459', strLocalityName = 'Augusta County', intMasterId = 4600018
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24463', strLocalityName = 'Augusta County', intMasterId = 4600019
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24467', strLocalityName = 'Augusta County', intMasterId = 4600020
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24472', strLocalityName = 'Augusta County', intMasterId = 4600021
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24477', strLocalityName = 'Augusta County', intMasterId = 4600022
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24479', strLocalityName = 'Augusta County', intMasterId = 4600023
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24482', strLocalityName = 'Augusta County', intMasterId = 4600024
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24483', strLocalityName = 'Augusta County', intMasterId = 4600025
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24485', strLocalityName = 'Augusta County', intMasterId = 4600026
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51015', strLocalityZipCode = '24486', strLocalityName = 'Augusta County', intMasterId = 4600027
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51017', strLocalityZipCode = '24412', strLocalityName = 'Bath County', intMasterId = 4600028
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51017', strLocalityZipCode = '24432', strLocalityName = 'Bath County', intMasterId = 4600029
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51017', strLocalityZipCode = '24445', strLocalityName = 'Bath County', intMasterId = 4600030
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51017', strLocalityZipCode = '24460', strLocalityName = 'Bath County', intMasterId = 4600031
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51017', strLocalityZipCode = '24484', strLocalityName = 'Bath County', intMasterId = 4600032
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51017', strLocalityZipCode = '24487', strLocalityName = 'Bath County', intMasterId = 4600033
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51530', strLocalityZipCode = '24416', strLocalityName = 'Buena Vista, City of', intMasterId = 4600034
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51660', strLocalityZipCode = '22801', strLocalityName = 'Harrisonburg, City of', intMasterId = 4600035
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51660', strLocalityZipCode = '22802', strLocalityName = 'Harrisonburg, City of', intMasterId = 4600036
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51660', strLocalityZipCode = '22807', strLocalityName = 'Harrisonburg, City of', intMasterId = 4600037
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51091', strLocalityZipCode = '24413', strLocalityName = 'Highland County', intMasterId = 4600038
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51091', strLocalityZipCode = '24433', strLocalityName = 'Highland County', intMasterId = 4600039
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51091', strLocalityZipCode = '24442', strLocalityName = 'Highland County', intMasterId = 4600040
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51091', strLocalityZipCode = '24458', strLocalityName = 'Highland County', intMasterId = 4600041
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51091', strLocalityZipCode = '24465', strLocalityName = 'Highland County', intMasterId = 4600042
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51091', strLocalityZipCode = '24468', strLocalityName = 'Highland County', intMasterId = 4600043
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51678', strLocalityZipCode = '24450', strLocalityName = 'Lexington, City of', intMasterId = 4600044
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24066', strLocalityName = 'Rockbridge County', intMasterId = 4600045
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24415', strLocalityName = 'Rockbridge County', intMasterId = 4600046
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24416', strLocalityName = 'Rockbridge County', intMasterId = 4600047
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24435', strLocalityName = 'Rockbridge County', intMasterId = 4600048
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24439', strLocalityName = 'Rockbridge County', intMasterId = 4600049
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24450', strLocalityName = 'Rockbridge County', intMasterId = 4600050
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24459', strLocalityName = 'Rockbridge County', intMasterId = 4600051
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24472', strLocalityName = 'Rockbridge County', intMasterId = 4600052
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24473', strLocalityName = 'Rockbridge County', intMasterId = 4600053
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24483', strLocalityName = 'Rockbridge County', intMasterId = 4600054
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24555', strLocalityName = 'Rockbridge County', intMasterId = 4600055
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24578', strLocalityName = 'Rockbridge County', intMasterId = 4600056
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51163', strLocalityZipCode = '24579', strLocalityName = 'Rockbridge County', intMasterId = 4600057
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22801', strLocalityName = 'Rockingham County', intMasterId = 4600058
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22802', strLocalityName = 'Rockingham County', intMasterId = 4600059
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22811', strLocalityName = 'Rockingham County', intMasterId = 4600060
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22812', strLocalityName = 'Rockingham County', intMasterId = 4600061
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22815', strLocalityName = 'Rockingham County', intMasterId = 4600062
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22820', strLocalityName = 'Rockingham County', intMasterId = 4600063
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22821', strLocalityName = 'Rockingham County', intMasterId = 4600064
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22827', strLocalityName = 'Rockingham County', intMasterId = 4600065
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22830', strLocalityName = 'Rockingham County', intMasterId = 4600066
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22831', strLocalityName = 'Rockingham County', intMasterId = 4600067
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22832', strLocalityName = 'Rockingham County', intMasterId = 4600068
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22833', strLocalityName = 'Rockingham County', intMasterId = 4600069
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22834', strLocalityName = 'Rockingham County', intMasterId = 4600070
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22840', strLocalityName = 'Rockingham County', intMasterId = 4600071
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22841', strLocalityName = 'Rockingham County', intMasterId = 4600072
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22844', strLocalityName = 'Rockingham County', intMasterId = 4600073
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22846', strLocalityName = 'Rockingham County', intMasterId = 4600074
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22848', strLocalityName = 'Rockingham County', intMasterId = 4600075
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22849', strLocalityName = 'Rockingham County', intMasterId = 4600076
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22850', strLocalityName = 'Rockingham County', intMasterId = 4600077
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '22853', strLocalityName = 'Rockingham County', intMasterId = 4600078
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '24441', strLocalityName = 'Rockingham County', intMasterId = 4600079
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '24471', strLocalityName = 'Rockingham County', intMasterId = 4600080
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51165', strLocalityZipCode = '24486', strLocalityName = 'Rockingham County', intMasterId = 4600081
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51790', strLocalityZipCode = '24401', strLocalityName = 'Staunton, City of', intMasterId = 4600082
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51790', strLocalityZipCode = '24402', strLocalityName = 'Staunton, City of', intMasterId = 4600083
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51790', strLocalityZipCode = '24482', strLocalityName = 'Staunton, City of', intMasterId = 4600084
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51820', strLocalityZipCode = '22952', strLocalityName = 'Waynesboro, City of', intMasterId = 4600085
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51820', strLocalityZipCode = '22980', strLocalityName = 'Waynesboro, City of', intMasterId = 4600086
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51550', strLocalityZipCode = '23320', strLocalityName = 'Chesapeake, City of', intMasterId = 4600087
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51550', strLocalityZipCode = '23321', strLocalityName = 'Chesapeake, City of', intMasterId = 4600088
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51550', strLocalityZipCode = '23322', strLocalityName = 'Chesapeake, City of', intMasterId = 4600089
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51550', strLocalityZipCode = '23323', strLocalityName = 'Chesapeake, City of', intMasterId = 4600090
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51550', strLocalityZipCode = '23324', strLocalityName = 'Chesapeake, City of', intMasterId = 4600091
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51550', strLocalityZipCode = '23325', strLocalityName = 'Chesapeake, City of', intMasterId = 4600092
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51550', strLocalityZipCode = '23326', strLocalityName = 'Chesapeake, City of', intMasterId = 4600093
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51550', strLocalityZipCode = '23464', strLocalityName = 'Chesapeake, City of', intMasterId = 4600094
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51620', strLocalityZipCode = '23851', strLocalityName = 'Franklin, City of', intMasterId = 4600095
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23605', strLocalityName = 'Hampton, City of', intMasterId = 4600096
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23630', strLocalityName = 'Hampton, City of', intMasterId = 4600097
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23651', strLocalityName = 'Hampton, City of', intMasterId = 4600098
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23661', strLocalityName = 'Hampton, City of', intMasterId = 4600099
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23663', strLocalityName = 'Hampton, City of', intMasterId = 4600100
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23664', strLocalityName = 'Hampton, City of', intMasterId = 4600101
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23665', strLocalityName = 'Hampton, City of', intMasterId = 4600102
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23666', strLocalityName = 'Hampton, City of', intMasterId = 4600103
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23667', strLocalityName = 'Hampton, City of', intMasterId = 4600104
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23668', strLocalityName = 'Hampton, City of', intMasterId = 4600105
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23669', strLocalityName = 'Hampton, City of', intMasterId = 4600106
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51650', strLocalityZipCode = '23681', strLocalityName = 'Hampton, City of', intMasterId = 4600107
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51093', strLocalityZipCode = '23314', strLocalityName = 'Isle of Wight County', intMasterId = 4600108
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51093', strLocalityZipCode = '23315', strLocalityName = 'Isle of Wight County', intMasterId = 4600109
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51093', strLocalityZipCode = '23430', strLocalityName = 'Isle of Wight County', intMasterId = 4600110
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51093', strLocalityZipCode = '23487', strLocalityName = 'Isle of Wight County', intMasterId = 4600111
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51093', strLocalityZipCode = '23851', strLocalityName = 'Isle of Wight County', intMasterId = 4600112
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51093', strLocalityZipCode = '23866', strLocalityName = 'Isle of Wight County', intMasterId = 4600113
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51093', strLocalityZipCode = '23898', strLocalityName = 'Isle of Wight County', intMasterId = 4600114
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51095', strLocalityZipCode = '23011', strLocalityName = 'James City County', intMasterId = 4600115
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51095', strLocalityZipCode = '23089', strLocalityName = 'James City County', intMasterId = 4600116
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51095', strLocalityZipCode = '23168', strLocalityName = 'James City County', intMasterId = 4600117
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51095', strLocalityZipCode = '23185', strLocalityName = 'James City County', intMasterId = 4600118
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51095', strLocalityZipCode = '23188', strLocalityName = 'James City County', intMasterId = 4600119
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51700', strLocalityZipCode = '23601', strLocalityName = 'Newport News, City of', intMasterId = 4600120
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51700', strLocalityZipCode = '23602', strLocalityName = 'Newport News, City of', intMasterId = 4600121
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51700', strLocalityZipCode = '23603', strLocalityName = 'Newport News, City of', intMasterId = 4600122
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51700', strLocalityZipCode = '23604', strLocalityName = 'Newport News, City of', intMasterId = 4600123
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51700', strLocalityZipCode = '23605', strLocalityName = 'Newport News, City of', intMasterId = 4600124
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51700', strLocalityZipCode = '23606', strLocalityName = 'Newport News, City of', intMasterId = 4600125
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51700', strLocalityZipCode = '23607', strLocalityName = 'Newport News, City of', intMasterId = 4600126
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51700', strLocalityZipCode = '23608', strLocalityName = 'Newport News, City of', intMasterId = 4600127
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51700', strLocalityZipCode = '23628', strLocalityName = 'Newport News, City of', intMasterId = 4600128
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23455', strLocalityName = 'Norfolk, City of', intMasterId = 4600129
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23459', strLocalityName = 'Norfolk, City of', intMasterId = 4600130
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23502', strLocalityName = 'Norfolk, City of', intMasterId = 4600131
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23503', strLocalityName = 'Norfolk, City of', intMasterId = 4600132
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23504', strLocalityName = 'Norfolk, City of', intMasterId = 4600133
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23505', strLocalityName = 'Norfolk, City of', intMasterId = 4600134
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23507', strLocalityName = 'Norfolk, City of', intMasterId = 4600135
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23508', strLocalityName = 'Norfolk, City of', intMasterId = 4600136
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23509', strLocalityName = 'Norfolk, City of', intMasterId = 4600137
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23510', strLocalityName = 'Norfolk, City of', intMasterId = 4600138
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23511', strLocalityName = 'Norfolk, City of', intMasterId = 4600139
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23513', strLocalityName = 'Norfolk, City of', intMasterId = 4600140
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23515', strLocalityName = 'Norfolk, City of', intMasterId = 4600141
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23517', strLocalityName = 'Norfolk, City of', intMasterId = 4600142
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23518', strLocalityName = 'Norfolk, City of', intMasterId = 4600143
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23519', strLocalityName = 'Norfolk, City of', intMasterId = 4600144
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23523', strLocalityName = 'Norfolk, City of', intMasterId = 4600145
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23529', strLocalityName = 'Norfolk, City of', intMasterId = 4600146
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51710', strLocalityZipCode = '23551', strLocalityName = 'Norfolk, City of', intMasterId = 4600147
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51735', strLocalityZipCode = '23662', strLocalityName = 'Poquoson, City of', intMasterId = 4600148
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51740', strLocalityZipCode = '23701', strLocalityName = 'Portsmouth, City of', intMasterId = 4600149
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51740', strLocalityZipCode = '23702', strLocalityName = 'Portsmouth, City of', intMasterId = 4600150
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51740', strLocalityZipCode = '23703', strLocalityName = 'Portsmouth, City of', intMasterId = 4600151
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51740', strLocalityZipCode = '23704', strLocalityName = 'Portsmouth, City of', intMasterId = 4600152
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51740', strLocalityZipCode = '23707', strLocalityName = 'Portsmouth, City of', intMasterId = 4600153
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51740', strLocalityZipCode = '23708', strLocalityName = 'Portsmouth, City of', intMasterId = 4600154
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51740', strLocalityZipCode = '23709', strLocalityName = 'Portsmouth, City of', intMasterId = 4600155
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23827', strLocalityName = 'Southampton County', intMasterId = 4600156
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23828', strLocalityName = 'Southampton County', intMasterId = 4600157
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23829', strLocalityName = 'Southampton County', intMasterId = 4600158
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23837', strLocalityName = 'Southampton County', intMasterId = 4600159
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23844', strLocalityName = 'Southampton County', intMasterId = 4600160
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23847', strLocalityName = 'Southampton County', intMasterId = 4600161
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23851', strLocalityName = 'Southampton County', intMasterId = 4600162
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23866', strLocalityName = 'Southampton County', intMasterId = 4600163
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23874', strLocalityName = 'Southampton County', intMasterId = 4600164
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23878', strLocalityName = 'Southampton County', intMasterId = 4600165
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23888', strLocalityName = 'Southampton County', intMasterId = 4600166
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51175', strLocalityZipCode = '23898', strLocalityName = 'Southampton County', intMasterId = 4600167
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51800', strLocalityZipCode = '23432', strLocalityName = 'Suffolk, City of', intMasterId = 4600168
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51800', strLocalityZipCode = '23433', strLocalityName = 'Suffolk, City of', intMasterId = 4600169
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51800', strLocalityZipCode = '23434', strLocalityName = 'Suffolk, City of', intMasterId = 4600170
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51800', strLocalityZipCode = '23435', strLocalityName = 'Suffolk, City of', intMasterId = 4600171
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51800', strLocalityZipCode = '23436', strLocalityName = 'Suffolk, City of', intMasterId = 4600172
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51800', strLocalityZipCode = '23437', strLocalityName = 'Suffolk, City of', intMasterId = 4600173
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51800', strLocalityZipCode = '23438', strLocalityName = 'Suffolk, City of', intMasterId = 4600174
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23451', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600175
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23452', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600176
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23453', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600177
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23454', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600178
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23455', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600179
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23456', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600180
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23457', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600181
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23459', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600182
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23460', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600183
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23461', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600184
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23462', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600185
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23463', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600186
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23464', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600187
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23465', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600188
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51810', strLocalityZipCode = '23479', strLocalityName = 'Virginia Beach, City of', intMasterId = 4600189
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51830', strLocalityZipCode = '23185', strLocalityName = 'Williamsburg, City of', intMasterId = 4600190
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51830', strLocalityZipCode = '23186', strLocalityName = 'Williamsburg, City of', intMasterId = 4600191
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51830', strLocalityZipCode = '23188', strLocalityName = 'Williamsburg, City of', intMasterId = 4600192
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51199', strLocalityZipCode = '23185', strLocalityName = 'York County', intMasterId = 4600193
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51199', strLocalityZipCode = '23188', strLocalityName = 'York County', intMasterId = 4600194
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51199', strLocalityZipCode = '23603', strLocalityName = 'York County', intMasterId = 4600195
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51199', strLocalityZipCode = '23665', strLocalityName = 'York County', intMasterId = 4600196
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51199', strLocalityZipCode = '23690', strLocalityName = 'York County', intMasterId = 4600197
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51199', strLocalityZipCode = '23691', strLocalityName = 'York County', intMasterId = 4600198
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51199', strLocalityZipCode = '23692', strLocalityName = 'York County', intMasterId = 4600199
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51199', strLocalityZipCode = '23693', strLocalityName = 'York County', intMasterId = 4600200
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51199', strLocalityZipCode = '23696', strLocalityName = 'York County', intMasterId = 4600201
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51021', strLocalityZipCode = '24084', strLocalityName = 'Bland County', intMasterId = 4600202
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51021', strLocalityZipCode = '24124', strLocalityName = 'Bland County', intMasterId = 4600203
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51021', strLocalityZipCode = '24134', strLocalityName = 'Bland County', intMasterId = 4600204
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51021', strLocalityZipCode = '24314', strLocalityName = 'Bland County', intMasterId = 4600205
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51021', strLocalityZipCode = '24315', strLocalityName = 'Bland County', intMasterId = 4600206
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51021', strLocalityZipCode = '24318', strLocalityName = 'Bland County', intMasterId = 4600207
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51021', strLocalityZipCode = '24366', strLocalityName = 'Bland County', intMasterId = 4600208
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51520', strLocalityZipCode = '24201', strLocalityName = 'Bristol, City of', intMasterId = 4600209
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51520', strLocalityZipCode = '24202', strLocalityName = 'Bristol, City of', intMasterId = 4600210
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24105', strLocalityName = 'Carroll County', intMasterId = 4600211
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24120', strLocalityName = 'Carroll County', intMasterId = 4600212
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24312', strLocalityName = 'Carroll County', intMasterId = 4600213
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24317', strLocalityName = 'Carroll County', intMasterId = 4600214
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24325', strLocalityName = 'Carroll County', intMasterId = 4600215
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24328', strLocalityName = 'Carroll County', intMasterId = 4600216
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24330', strLocalityName = 'Carroll County', intMasterId = 4600217
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24333', strLocalityName = 'Carroll County', intMasterId = 4600218
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24343', strLocalityName = 'Carroll County', intMasterId = 4600219
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24347', strLocalityName = 'Carroll County', intMasterId = 4600220
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24350', strLocalityName = 'Carroll County', intMasterId = 4600221
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24351', strLocalityName = 'Carroll County', intMasterId = 4600222
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24352', strLocalityName = 'Carroll County', intMasterId = 4600223
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24380', strLocalityName = 'Carroll County', intMasterId = 4600224
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51035', strLocalityZipCode = '24381', strLocalityName = 'Carroll County', intMasterId = 4600225
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51640', strLocalityZipCode = '24333', strLocalityName = 'Galax, City of', intMasterId = 4600226
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51077', strLocalityZipCode = '24292', strLocalityName = 'Grayson County', intMasterId = 4600227
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51077', strLocalityZipCode = '24326', strLocalityName = 'Grayson County', intMasterId = 4600228
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51077', strLocalityZipCode = '24330', strLocalityName = 'Grayson County', intMasterId = 4600229
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51077', strLocalityZipCode = '24333', strLocalityName = 'Grayson County', intMasterId = 4600230
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51077', strLocalityZipCode = '24348', strLocalityName = 'Grayson County', intMasterId = 4600231
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51077', strLocalityZipCode = '24350', strLocalityName = 'Grayson County', intMasterId = 4600232
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51077', strLocalityZipCode = '24363', strLocalityName = 'Grayson County', intMasterId = 4600233
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51077', strLocalityZipCode = '24378', strLocalityName = 'Grayson County', intMasterId = 4600234
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51173', strLocalityZipCode = '24236', strLocalityName = 'Smyth County', intMasterId = 4600235
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51173', strLocalityZipCode = '24311', strLocalityName = 'Smyth County', intMasterId = 4600236
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51173', strLocalityZipCode = '24318', strLocalityName = 'Smyth County', intMasterId = 4600237
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51173', strLocalityZipCode = '24319', strLocalityName = 'Smyth County', intMasterId = 4600238
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51173', strLocalityZipCode = '24354', strLocalityName = 'Smyth County', intMasterId = 4600239
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51173', strLocalityZipCode = '24368', strLocalityName = 'Smyth County', intMasterId = 4600240
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51173', strLocalityZipCode = '24370', strLocalityName = 'Smyth County', intMasterId = 4600241
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51173', strLocalityZipCode = '24374', strLocalityName = 'Smyth County', intMasterId = 4600242
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51173', strLocalityZipCode = '24375', strLocalityName = 'Smyth County', intMasterId = 4600243
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51173', strLocalityZipCode = '24378', strLocalityName = 'Smyth County', intMasterId = 4600244
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51191', strLocalityZipCode = '24202', strLocalityName = 'Washington County', intMasterId = 4600245
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51191', strLocalityZipCode = '24210', strLocalityName = 'Washington County', intMasterId = 4600246
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51191', strLocalityZipCode = '24211', strLocalityName = 'Washington County', intMasterId = 4600247
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51191', strLocalityZipCode = '24236', strLocalityName = 'Washington County', intMasterId = 4600248
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51191', strLocalityZipCode = '24270', strLocalityName = 'Washington County', intMasterId = 4600249
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51191', strLocalityZipCode = '24319', strLocalityName = 'Washington County', intMasterId = 4600250
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51191', strLocalityZipCode = '24340', strLocalityName = 'Washington County', intMasterId = 4600251
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51191', strLocalityZipCode = '24361', strLocalityName = 'Washington County', intMasterId = 4600252
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51191', strLocalityZipCode = '24370', strLocalityName = 'Washington County', intMasterId = 4600253
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51197', strLocalityZipCode = '24311', strLocalityName = 'Wythe County', intMasterId = 4600254
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51197', strLocalityZipCode = '24312', strLocalityName = 'Wythe County', intMasterId = 4600255
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51197', strLocalityZipCode = '24313', strLocalityName = 'Wythe County', intMasterId = 4600256
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51197', strLocalityZipCode = '24322', strLocalityName = 'Wythe County', intMasterId = 4600257
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51197', strLocalityZipCode = '24323', strLocalityName = 'Wythe County', intMasterId = 4600258
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51197', strLocalityZipCode = '24324', strLocalityName = 'Wythe County', intMasterId = 4600259
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51197', strLocalityZipCode = '24350', strLocalityName = 'Wythe County', intMasterId = 4600260
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51197', strLocalityZipCode = '24360', strLocalityName = 'Wythe County', intMasterId = 4600261
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51197', strLocalityZipCode = '24368', strLocalityName = 'Wythe County', intMasterId = 4600262
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51197', strLocalityZipCode = '24374', strLocalityName = 'Wythe County', intMasterId = 4600263
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51197', strLocalityZipCode = '24382', strLocalityName = 'Wythe County', intMasterId = 4600264
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51063', strLocalityZipCode = '24072', strLocalityName = 'Floyd County', intMasterId = 4600265
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51063', strLocalityZipCode = '24079', strLocalityName = 'Floyd County', intMasterId = 4600266
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51063', strLocalityZipCode = '24091', strLocalityName = 'Floyd County', intMasterId = 4600267
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51063', strLocalityZipCode = '24105', strLocalityName = 'Floyd County', intMasterId = 4600268
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51063', strLocalityZipCode = '24120', strLocalityName = 'Floyd County', intMasterId = 4600269
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51063', strLocalityZipCode = '24138', strLocalityName = 'Floyd County', intMasterId = 4600270
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51063', strLocalityZipCode = '24141', strLocalityName = 'Floyd County', intMasterId = 4600271
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51063', strLocalityZipCode = '24149', strLocalityName = 'Floyd County', intMasterId = 4600272
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51063', strLocalityZipCode = '24162', strLocalityName = 'Floyd County', intMasterId = 4600273
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51063', strLocalityZipCode = '24380', strLocalityName = 'Floyd County', intMasterId = 4600274
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51071', strLocalityZipCode = '24086', strLocalityName = 'Giles County', intMasterId = 4600275
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51071', strLocalityZipCode = '24093', strLocalityName = 'Giles County', intMasterId = 4600276
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51071', strLocalityZipCode = '24124', strLocalityName = 'Giles County', intMasterId = 4600277
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51071', strLocalityZipCode = '24128', strLocalityName = 'Giles County', intMasterId = 4600278
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51071', strLocalityZipCode = '24134', strLocalityName = 'Giles County', intMasterId = 4600279
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51071', strLocalityZipCode = '24136', strLocalityName = 'Giles County', intMasterId = 4600280
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51071', strLocalityZipCode = '24147', strLocalityName = 'Giles County', intMasterId = 4600281
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51071', strLocalityZipCode = '24150', strLocalityName = 'Giles County', intMasterId = 4600282
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51071', strLocalityZipCode = '24167', strLocalityName = 'Giles County', intMasterId = 4600283
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51071', strLocalityZipCode = '24315', strLocalityName = 'Giles County', intMasterId = 4600284
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24059', strLocalityName = 'Montgomery County', intMasterId = 4600285
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24060', strLocalityName = 'Montgomery County', intMasterId = 4600286
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24061', strLocalityName = 'Montgomery County', intMasterId = 4600287
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24070', strLocalityName = 'Montgomery County', intMasterId = 4600288
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24073', strLocalityName = 'Montgomery County', intMasterId = 4600289
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24087', strLocalityName = 'Montgomery County', intMasterId = 4600290
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24128', strLocalityName = 'Montgomery County', intMasterId = 4600291
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24138', strLocalityName = 'Montgomery County', intMasterId = 4600292
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24141', strLocalityName = 'Montgomery County', intMasterId = 4600293
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24149', strLocalityName = 'Montgomery County', intMasterId = 4600294
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24162', strLocalityName = 'Montgomery County', intMasterId = 4600295
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51121', strLocalityZipCode = '24347', strLocalityName = 'Montgomery County', intMasterId = 4600296
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51155', strLocalityZipCode = '24058', strLocalityName = 'Pulaski County', intMasterId = 4600297
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51155', strLocalityZipCode = '24084', strLocalityName = 'Pulaski County', intMasterId = 4600298
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51155', strLocalityZipCode = '24126', strLocalityName = 'Pulaski County', intMasterId = 4600299
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51155', strLocalityZipCode = '24129', strLocalityName = 'Pulaski County', intMasterId = 4600300
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51155', strLocalityZipCode = '24132', strLocalityName = 'Pulaski County', intMasterId = 4600301
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51155', strLocalityZipCode = '24141', strLocalityName = 'Pulaski County', intMasterId = 4600302
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51155', strLocalityZipCode = '24301', strLocalityName = 'Pulaski County', intMasterId = 4600303
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51155', strLocalityZipCode = '24324', strLocalityName = 'Pulaski County', intMasterId = 4600304
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51155', strLocalityZipCode = '24347', strLocalityName = 'Pulaski County', intMasterId = 4600305
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51750', strLocalityZipCode = '24141', strLocalityName = 'Radford, City of', intMasterId = 4600306
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51750', strLocalityZipCode = '24142', strLocalityName = 'Radford, City of', intMasterId = 4600307
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51043', strLocalityZipCode = '20130', strLocalityName = 'Clarke County', intMasterId = 4600308
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51043', strLocalityZipCode = '20135', strLocalityName = 'Clarke County', intMasterId = 4600309
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51043', strLocalityZipCode = '22611', strLocalityName = 'Clarke County', intMasterId = 4600310
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51043', strLocalityZipCode = '22620', strLocalityName = 'Clarke County', intMasterId = 4600311
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51043', strLocalityZipCode = '22646', strLocalityName = 'Clarke County', intMasterId = 4600312
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51043', strLocalityZipCode = '22663', strLocalityName = 'Clarke County', intMasterId = 4600313
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51069', strLocalityZipCode = '22602', strLocalityName = 'Frederick County', intMasterId = 4600314
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51069', strLocalityZipCode = '22603', strLocalityName = 'Frederick County', intMasterId = 4600315
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51069', strLocalityZipCode = '22622', strLocalityName = 'Frederick County', intMasterId = 4600316
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51069', strLocalityZipCode = '22624', strLocalityName = 'Frederick County', intMasterId = 4600317
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51069', strLocalityZipCode = '22625', strLocalityName = 'Frederick County', intMasterId = 4600318
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51069', strLocalityZipCode = '22637', strLocalityName = 'Frederick County', intMasterId = 4600319
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51069', strLocalityZipCode = '22645', strLocalityName = 'Frederick County', intMasterId = 4600320
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51069', strLocalityZipCode = '22654', strLocalityName = 'Frederick County', intMasterId = 4600321
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51069', strLocalityZipCode = '22655', strLocalityName = 'Frederick County', intMasterId = 4600322
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51069', strLocalityZipCode = '22656', strLocalityName = 'Frederick County', intMasterId = 4600323
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51139', strLocalityZipCode = '22610', strLocalityName = 'Page County', intMasterId = 4600324
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51139', strLocalityZipCode = '22650', strLocalityName = 'Page County', intMasterId = 4600325
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51139', strLocalityZipCode = '22743', strLocalityName = 'Page County', intMasterId = 4600326
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51139', strLocalityZipCode = '22815', strLocalityName = 'Page County', intMasterId = 4600327
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51139', strLocalityZipCode = '22827', strLocalityName = 'Page County', intMasterId = 4600328
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51139', strLocalityZipCode = '22835', strLocalityName = 'Page County', intMasterId = 4600329
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51139', strLocalityZipCode = '22849', strLocalityName = 'Page County', intMasterId = 4600330
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51139', strLocalityZipCode = '22851', strLocalityName = 'Page County', intMasterId = 4600331
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22626', strLocalityName = 'Shenandoah County', intMasterId = 4600332
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22641', strLocalityName = 'Shenandoah County', intMasterId = 4600333
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22644', strLocalityName = 'Shenandoah County', intMasterId = 4600334
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22645', strLocalityName = 'Shenandoah County', intMasterId = 4600335
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22652', strLocalityName = 'Shenandoah County', intMasterId = 4600336
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22654', strLocalityName = 'Shenandoah County', intMasterId = 4600337
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22657', strLocalityName = 'Shenandoah County', intMasterId = 4600338
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22660', strLocalityName = 'Shenandoah County', intMasterId = 4600339
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22664', strLocalityName = 'Shenandoah County', intMasterId = 4600340
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22810', strLocalityName = 'Shenandoah County', intMasterId = 4600341
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22815', strLocalityName = 'Shenandoah County', intMasterId = 4600342
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22824', strLocalityName = 'Shenandoah County', intMasterId = 4600343
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22842', strLocalityName = 'Shenandoah County', intMasterId = 4600344
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22844', strLocalityName = 'Shenandoah County', intMasterId = 4600345
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22845', strLocalityName = 'Shenandoah County', intMasterId = 4600346
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22847', strLocalityName = 'Shenandoah County', intMasterId = 4600347
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22849', strLocalityName = 'Shenandoah County', intMasterId = 4600348
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51171', strLocalityZipCode = '22853', strLocalityName = 'Shenandoah County', intMasterId = 4600349
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51187', strLocalityZipCode = '22610', strLocalityName = 'Warren County', intMasterId = 4600350
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51187', strLocalityZipCode = '22630', strLocalityName = 'Warren County', intMasterId = 4600351
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51187', strLocalityZipCode = '22642', strLocalityName = 'Warren County', intMasterId = 4600352
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51187', strLocalityZipCode = '22649', strLocalityName = 'Warren County', intMasterId = 4600353
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51840', strLocalityZipCode = '22601', strLocalityName = 'Winchester, City of', intMasterId = 4600354
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51840', strLocalityZipCode = '22602', strLocalityName = 'Winchester, City of', intMasterId = 4600355
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51840', strLocalityZipCode = '22603', strLocalityName = 'Winchester, City of', intMasterId = 4600356
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51510', strLocalityZipCode = '22206', strLocalityName = 'Alexandria, City of', intMasterId = 4600357
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51510', strLocalityZipCode = '22301', strLocalityName = 'Alexandria, City of', intMasterId = 4600358
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51510', strLocalityZipCode = '22302', strLocalityName = 'Alexandria, City of', intMasterId = 4600359
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51510', strLocalityZipCode = '22304', strLocalityName = 'Alexandria, City of', intMasterId = 4600360
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51510', strLocalityZipCode = '22305', strLocalityName = 'Alexandria, City of', intMasterId = 4600361
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51510', strLocalityZipCode = '22311', strLocalityName = 'Alexandria, City of', intMasterId = 4600362
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51510', strLocalityZipCode = '22312', strLocalityName = 'Alexandria, City of', intMasterId = 4600363
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51510', strLocalityZipCode = '22314', strLocalityName = 'Alexandria, City of', intMasterId = 4600364
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51013', strLocalityZipCode = '22101', strLocalityName = 'Arlington County', intMasterId = 4600365
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51013', strLocalityZipCode = '22201', strLocalityName = 'Arlington County', intMasterId = 4600366
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51013', strLocalityZipCode = '22202', strLocalityName = 'Arlington County', intMasterId = 4600367
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51013', strLocalityZipCode = '22203', strLocalityName = 'Arlington County', intMasterId = 4600368
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51013', strLocalityZipCode = '22204', strLocalityName = 'Arlington County', intMasterId = 4600369
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51013', strLocalityZipCode = '22205', strLocalityName = 'Arlington County', intMasterId = 4600370
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51013', strLocalityZipCode = '22206', strLocalityName = 'Arlington County', intMasterId = 4600371
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51013', strLocalityZipCode = '22207', strLocalityName = 'Arlington County', intMasterId = 4600372
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51013', strLocalityZipCode = '22209', strLocalityName = 'Arlington County', intMasterId = 4600373
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51013', strLocalityZipCode = '22211', strLocalityName = 'Arlington County', intMasterId = 4600374
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51013', strLocalityZipCode = '22213', strLocalityName = 'Arlington County', intMasterId = 4600375
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '20120', strLocalityName = 'Fairfax County', intMasterId = 4600376
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '20121', strLocalityName = 'Fairfax County', intMasterId = 4600377
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '20124', strLocalityName = 'Fairfax County', intMasterId = 4600378
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '20151', strLocalityName = 'Fairfax County', intMasterId = 4600379
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '20166', strLocalityName = 'Fairfax County', intMasterId = 4600380
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '20170', strLocalityName = 'Fairfax County', intMasterId = 4600381
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '20171', strLocalityName = 'Fairfax County', intMasterId = 4600382
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '20190', strLocalityName = 'Fairfax County', intMasterId = 4600383
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '20191', strLocalityName = 'Fairfax County', intMasterId = 4600384
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '20194', strLocalityName = 'Fairfax County', intMasterId = 4600385
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22003', strLocalityName = 'Fairfax County', intMasterId = 4600386
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22015', strLocalityName = 'Fairfax County', intMasterId = 4600387
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22027', strLocalityName = 'Fairfax County', intMasterId = 4600388
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22030', strLocalityName = 'Fairfax County', intMasterId = 4600389
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22031', strLocalityName = 'Fairfax County', intMasterId = 4600390
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22032', strLocalityName = 'Fairfax County', intMasterId = 4600391
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22033', strLocalityName = 'Fairfax County', intMasterId = 4600392
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22039', strLocalityName = 'Fairfax County', intMasterId = 4600393
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22041', strLocalityName = 'Fairfax County', intMasterId = 4600394
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22042', strLocalityName = 'Fairfax County', intMasterId = 4600395
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22043', strLocalityName = 'Fairfax County', intMasterId = 4600396
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22044', strLocalityName = 'Fairfax County', intMasterId = 4600397
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22046', strLocalityName = 'Fairfax County', intMasterId = 4600398
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22060', strLocalityName = 'Fairfax County', intMasterId = 4600399
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22066', strLocalityName = 'Fairfax County', intMasterId = 4600400
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22079', strLocalityName = 'Fairfax County', intMasterId = 4600401
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22101', strLocalityName = 'Fairfax County', intMasterId = 4600402
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22102', strLocalityName = 'Fairfax County', intMasterId = 4600403
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22124', strLocalityName = 'Fairfax County', intMasterId = 4600404
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22150', strLocalityName = 'Fairfax County', intMasterId = 4600405
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22151', strLocalityName = 'Fairfax County', intMasterId = 4600406
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22152', strLocalityName = 'Fairfax County', intMasterId = 4600407
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22153', strLocalityName = 'Fairfax County', intMasterId = 4600408
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22180', strLocalityName = 'Fairfax County', intMasterId = 4600409
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22181', strLocalityName = 'Fairfax County', intMasterId = 4600410
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22182', strLocalityName = 'Fairfax County', intMasterId = 4600411
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22207', strLocalityName = 'Fairfax County', intMasterId = 4600412
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22303', strLocalityName = 'Fairfax County', intMasterId = 4600413
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22304', strLocalityName = 'Fairfax County', intMasterId = 4600414
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22306', strLocalityName = 'Fairfax County', intMasterId = 4600415
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22307', strLocalityName = 'Fairfax County', intMasterId = 4600416
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22308', strLocalityName = 'Fairfax County', intMasterId = 4600417
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22309', strLocalityName = 'Fairfax County', intMasterId = 4600418
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22310', strLocalityName = 'Fairfax County', intMasterId = 4600419
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22311', strLocalityName = 'Fairfax County', intMasterId = 4600420
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22312', strLocalityName = 'Fairfax County', intMasterId = 4600421
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51059', strLocalityZipCode = '22315', strLocalityName = 'Fairfax County', intMasterId = 4600422
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51600', strLocalityZipCode = '22030', strLocalityName = 'Fairfax, City of', intMasterId = 4600423
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51600', strLocalityZipCode = '22031', strLocalityName = 'Fairfax, City of', intMasterId = 4600424
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51600', strLocalityZipCode = '22032', strLocalityName = 'Fairfax, City of', intMasterId = 4600425
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51610', strLocalityZipCode = '22042', strLocalityName = 'Falls Church, City of', intMasterId = 4600426
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51610', strLocalityZipCode = '22044', strLocalityName = 'Falls Church, City of', intMasterId = 4600427
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51610', strLocalityZipCode = '22046', strLocalityName = 'Falls Church, City of', intMasterId = 4600428
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20105', strLocalityName = 'Loudoun County', intMasterId = 4600429
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20120', strLocalityName = 'Loudoun County', intMasterId = 4600430
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20129', strLocalityName = 'Loudoun County', intMasterId = 4600431
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20132', strLocalityName = 'Loudoun County', intMasterId = 4600432
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20141', strLocalityName = 'Loudoun County', intMasterId = 4600433
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20147', strLocalityName = 'Loudoun County', intMasterId = 4600434
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20148', strLocalityName = 'Loudoun County', intMasterId = 4600435
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20152', strLocalityName = 'Loudoun County', intMasterId = 4600436
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20158', strLocalityName = 'Loudoun County', intMasterId = 4600437
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20164', strLocalityName = 'Loudoun County', intMasterId = 4600438
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20165', strLocalityName = 'Loudoun County', intMasterId = 4600439
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20166', strLocalityName = 'Loudoun County', intMasterId = 4600440
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20175', strLocalityName = 'Loudoun County', intMasterId = 4600441
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20176', strLocalityName = 'Loudoun County', intMasterId = 4600442
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20180', strLocalityName = 'Loudoun County', intMasterId = 4600443
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '20197', strLocalityName = 'Loudoun County', intMasterId = 4600444
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51107', strLocalityZipCode = '22066', strLocalityName = 'Loudoun County', intMasterId = 4600445
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51630', strLocalityZipCode = '22401', strLocalityName = 'Fredericksburg, City of', intMasterId = 4600446
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51685', strLocalityZipCode = '20110', strLocalityName = 'Manassas Park, City of', intMasterId = 4600447
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51685', strLocalityZipCode = '20111', strLocalityName = 'Manassas Park, City of', intMasterId = 4600448
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51683', strLocalityZipCode = '20110', strLocalityName = 'Manassas, City of', intMasterId = 4600449
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '20109', strLocalityName = 'Prince William County', intMasterId = 4600450
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '20110', strLocalityName = 'Prince William County', intMasterId = 4600451
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '20111', strLocalityName = 'Prince William County', intMasterId = 4600452
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '20112', strLocalityName = 'Prince William County', intMasterId = 4600453
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '20136', strLocalityName = 'Prince William County', intMasterId = 4600454
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '20143', strLocalityName = 'Prince William County', intMasterId = 4600455
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '20155', strLocalityName = 'Prince William County', intMasterId = 4600456
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '20169', strLocalityName = 'Prince William County', intMasterId = 4600457
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '20181', strLocalityName = 'Prince William County', intMasterId = 4600458
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '20182', strLocalityName = 'Prince William County', intMasterId = 4600459
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '22026', strLocalityName = 'Prince William County', intMasterId = 4600460
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '22134', strLocalityName = 'Prince William County', intMasterId = 4600461
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '22135', strLocalityName = 'Prince William County', intMasterId = 4600462
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '22172', strLocalityName = 'Prince William County', intMasterId = 4600463
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '22191', strLocalityName = 'Prince William County', intMasterId = 4600464
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '22192', strLocalityName = 'Prince William County', intMasterId = 4600465
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51153', strLocalityZipCode = '22193', strLocalityName = 'Prince William County', intMasterId = 4600466
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51177', strLocalityZipCode = '22407', strLocalityName = 'Spotsylvania County', intMasterId = 4600467
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51177', strLocalityZipCode = '22408', strLocalityName = 'Spotsylvania County', intMasterId = 4600468
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51177', strLocalityZipCode = '22534', strLocalityName = 'Spotsylvania County', intMasterId = 4600469
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51177', strLocalityZipCode = '22551', strLocalityName = 'Spotsylvania County', intMasterId = 4600470
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51177', strLocalityZipCode = '22553', strLocalityName = 'Spotsylvania County', intMasterId = 4600471
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51177', strLocalityZipCode = '22580', strLocalityName = 'Spotsylvania County', intMasterId = 4600472
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51177', strLocalityZipCode = '22960', strLocalityName = 'Spotsylvania County', intMasterId = 4600473
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51177', strLocalityZipCode = '23024', strLocalityName = 'Spotsylvania County', intMasterId = 4600474
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51177', strLocalityZipCode = '23117', strLocalityName = 'Spotsylvania County', intMasterId = 4600475
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51179', strLocalityZipCode = '22135', strLocalityName = 'Stafford County', intMasterId = 4600476
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51179', strLocalityZipCode = '22405', strLocalityName = 'Stafford County', intMasterId = 4600477
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51179', strLocalityZipCode = '22406', strLocalityName = 'Stafford County', intMasterId = 4600478
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51179', strLocalityZipCode = '22412', strLocalityName = 'Stafford County', intMasterId = 4600479
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51179', strLocalityZipCode = '22554', strLocalityName = 'Stafford County', intMasterId = 4600480
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51179', strLocalityZipCode = '22556', strLocalityName = 'Stafford County', intMasterId = 4600481
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51005', strLocalityZipCode = '24422', strLocalityName = 'Alleghany County', intMasterId = 4600482
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51005', strLocalityZipCode = '24426', strLocalityName = 'Alleghany County', intMasterId = 4600483
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51005', strLocalityZipCode = '24445', strLocalityName = 'Alleghany County', intMasterId = 4600484
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51005', strLocalityZipCode = '24448', strLocalityName = 'Alleghany County', intMasterId = 4600485
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51005', strLocalityZipCode = '24457', strLocalityName = 'Alleghany County', intMasterId = 4600486
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51005', strLocalityZipCode = '24474', strLocalityName = 'Alleghany County', intMasterId = 4600487
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24012', strLocalityName = 'Botetourt County', intMasterId = 4600488
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24019', strLocalityName = 'Botetourt County', intMasterId = 4600489
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24050', strLocalityName = 'Botetourt County', intMasterId = 4600490
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24064', strLocalityName = 'Botetourt County', intMasterId = 4600491
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24066', strLocalityName = 'Botetourt County', intMasterId = 4600492
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24077', strLocalityName = 'Botetourt County', intMasterId = 4600493
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24083', strLocalityName = 'Botetourt County', intMasterId = 4600494
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24085', strLocalityName = 'Botetourt County', intMasterId = 4600495
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24090', strLocalityName = 'Botetourt County', intMasterId = 4600496
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24130', strLocalityName = 'Botetourt County', intMasterId = 4600497
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24153', strLocalityName = 'Botetourt County', intMasterId = 4600498
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24175', strLocalityName = 'Botetourt County', intMasterId = 4600499
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24438', strLocalityName = 'Botetourt County', intMasterId = 4600500
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51023', strLocalityZipCode = '24579', strLocalityName = 'Botetourt County', intMasterId = 4600501
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51580', strLocalityZipCode = '24426', strLocalityName = 'Covington, City of', intMasterId = 4600502
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51045', strLocalityZipCode = '24070', strLocalityName = 'Craig County', intMasterId = 4600503
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51045', strLocalityZipCode = '24127', strLocalityName = 'Craig County', intMasterId = 4600504
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51045', strLocalityZipCode = '24128', strLocalityName = 'Craig County', intMasterId = 4600505
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51045', strLocalityZipCode = '24131', strLocalityName = 'Craig County', intMasterId = 4600506
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24055', strLocalityName = 'Franklin County', intMasterId = 4600507
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24059', strLocalityName = 'Franklin County', intMasterId = 4600508
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24065', strLocalityName = 'Franklin County', intMasterId = 4600509
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24067', strLocalityName = 'Franklin County', intMasterId = 4600510
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24088', strLocalityName = 'Franklin County', intMasterId = 4600511
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24091', strLocalityName = 'Franklin County', intMasterId = 4600512
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24092', strLocalityName = 'Franklin County', intMasterId = 4600513
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24101', strLocalityName = 'Franklin County', intMasterId = 4600514
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24102', strLocalityName = 'Franklin County', intMasterId = 4600515
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24112', strLocalityName = 'Franklin County', intMasterId = 4600516
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24121', strLocalityName = 'Franklin County', intMasterId = 4600517
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24137', strLocalityName = 'Franklin County', intMasterId = 4600518
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24146', strLocalityName = 'Franklin County', intMasterId = 4600519
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24151', strLocalityName = 'Franklin County', intMasterId = 4600520
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24176', strLocalityName = 'Franklin County', intMasterId = 4600521
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51067', strLocalityZipCode = '24184', strLocalityName = 'Franklin County', intMasterId = 4600522
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24012', strLocalityName = 'Roanoke County', intMasterId = 4600523
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24014', strLocalityName = 'Roanoke County', intMasterId = 4600524
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24018', strLocalityName = 'Roanoke County', intMasterId = 4600525
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24019', strLocalityName = 'Roanoke County', intMasterId = 4600526
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24020', strLocalityName = 'Roanoke County', intMasterId = 4600527
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24059', strLocalityName = 'Roanoke County', intMasterId = 4600528
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24065', strLocalityName = 'Roanoke County', intMasterId = 4600529
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24070', strLocalityName = 'Roanoke County', intMasterId = 4600530
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24087', strLocalityName = 'Roanoke County', intMasterId = 4600531
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24153', strLocalityName = 'Roanoke County', intMasterId = 4600532
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24175', strLocalityName = 'Roanoke County', intMasterId = 4600533
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51161', strLocalityZipCode = '24179', strLocalityName = 'Roanoke County', intMasterId = 4600534
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24011', strLocalityName = 'Roanoke, City of', intMasterId = 4600535
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24012', strLocalityName = 'Roanoke, City of', intMasterId = 4600536
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24013', strLocalityName = 'Roanoke, City of', intMasterId = 4600537
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24014', strLocalityName = 'Roanoke, City of', intMasterId = 4600538
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24015', strLocalityName = 'Roanoke, City of', intMasterId = 4600539
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24016', strLocalityName = 'Roanoke, City of', intMasterId = 4600540
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24017', strLocalityName = 'Roanoke, City of', intMasterId = 4600541
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24018', strLocalityName = 'Roanoke, City of', intMasterId = 4600542
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24019', strLocalityName = 'Roanoke, City of', intMasterId = 4600543
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24020', strLocalityName = 'Roanoke, City of', intMasterId = 4600544
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24050', strLocalityName = 'Roanoke, City of', intMasterId = 4600545
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24155', strLocalityName = 'Roanoke, City of', intMasterId = 4600546
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51770', strLocalityZipCode = '24157', strLocalityName = 'Roanoke, City of', intMasterId = 4600547
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51775', strLocalityZipCode = '24153', strLocalityName = 'Salem, City of', intMasterId = 4600548
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51775', strLocalityZipCode = '24155', strLocalityName = 'Salem, City of', intMasterId = 4600549
------UNION ALL SELECT intLocalityId = 0, strLocalityCode = '51775', strLocalityZipCode = '24157', strLocalityName = 'Salem, City of', intMasterId = 4600550

          SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23301'	, strLocalityName =	'Accomack County'	, intMasterId =	4600551
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23302'	, strLocalityName =	'Accomack County'	, intMasterId =	4600552
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23303'	, strLocalityName =	'Accomack County'	, intMasterId =	4600553
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23306'	, strLocalityName =	'Accomack County'	, intMasterId =	4600554
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23308'	, strLocalityName =	'Accomack County'	, intMasterId =	4600555
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23336'	, strLocalityName =	'Accomack County'	, intMasterId =	4600556
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23337'	, strLocalityName =	'Accomack County'	, intMasterId =	4600557
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23341'	, strLocalityName =	'Accomack County'	, intMasterId =	4600558
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23345'	, strLocalityName =	'Accomack County'	, intMasterId =	4600559
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23356'	, strLocalityName =	'Accomack County'	, intMasterId =	4600560
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23357'	, strLocalityName =	'Accomack County'	, intMasterId =	4600561
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23358'	, strLocalityName =	'Accomack County'	, intMasterId =	4600562
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23359'	, strLocalityName =	'Accomack County'	, intMasterId =	4600563
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23389'	, strLocalityName =	'Accomack County'	, intMasterId =	4600564
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23395'	, strLocalityName =	'Accomack County'	, intMasterId =	4600565
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23396'	, strLocalityName =	'Accomack County'	, intMasterId =	4600566
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23399'	, strLocalityName =	'Accomack County'	, intMasterId =	4600567
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23401'	, strLocalityName =	'Accomack County'	, intMasterId =	4600568
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23404'	, strLocalityName =	'Accomack County'	, intMasterId =	4600569
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23407'	, strLocalityName =	'Accomack County'	, intMasterId =	4600570
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23409'	, strLocalityName =	'Accomack County'	, intMasterId =	4600571
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23410'	, strLocalityName =	'Accomack County'	, intMasterId =	4600572
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23412'	, strLocalityName =	'Accomack County'	, intMasterId =	4600573
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23414'	, strLocalityName =	'Accomack County'	, intMasterId =	4600574
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23415'	, strLocalityName =	'Accomack County'	, intMasterId =	4600575
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23416'	, strLocalityName =	'Accomack County'	, intMasterId =	4600576
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23417'	, strLocalityName =	'Accomack County'	, intMasterId =	4600577
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23418'	, strLocalityName =	'Accomack County'	, intMasterId =	4600578
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23420'	, strLocalityName =	'Accomack County'	, intMasterId =	4600579
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23421'	, strLocalityName =	'Accomack County'	, intMasterId =	4600580
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23422'	, strLocalityName =	'Accomack County'	, intMasterId =	4600581
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23423'	, strLocalityName =	'Accomack County'	, intMasterId =	4600582
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23426'	, strLocalityName =	'Accomack County'	, intMasterId =	4600583
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23427'	, strLocalityName =	'Accomack County'	, intMasterId =	4600584
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23440'	, strLocalityName =	'Accomack County'	, intMasterId =	4600585
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23441'	, strLocalityName =	'Accomack County'	, intMasterId =	4600586
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23442'	, strLocalityName =	'Accomack County'	, intMasterId =	4600587
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23480'	, strLocalityName =	'Accomack County'	, intMasterId =	4600588
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23483'	, strLocalityName =	'Accomack County'	, intMasterId =	4600589
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51001'	, strLocalityZipCode =	'23488'	, strLocalityName =	'Accomack County'	, intMasterId =	4600590
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22901'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600591
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22902'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600592
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22903'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600593
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22911'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600594
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22920'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600595
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22923'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600596
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22924'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600597
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22931'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600598
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22932'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600599
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22935'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600600
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22936'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600601
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22937'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600602
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22938'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600603
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22940'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600604
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22942'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600605
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22943'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600606
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22945'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600607
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22946'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600608
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22947'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600609
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22959'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600610
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22968'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600611
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22969'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600612
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22974'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600613
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'22987'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600614
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'24562'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600615
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51003'	, strLocalityZipCode =	'24590'	, strLocalityName =	'Albemarle County'	, intMasterId =	4600616
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51510'	, strLocalityZipCode =	'22206'	, strLocalityName =	'Alexandria, City of'	, intMasterId =	4600617
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51510'	, strLocalityZipCode =	'22301'	, strLocalityName =	'Alexandria, City of'	, intMasterId =	4600618
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51510'	, strLocalityZipCode =	'22302'	, strLocalityName =	'Alexandria, City of'	, intMasterId =	4600619
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51510'	, strLocalityZipCode =	'22304'	, strLocalityName =	'Alexandria, City of'	, intMasterId =	4600620
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51510'	, strLocalityZipCode =	'22305'	, strLocalityName =	'Alexandria, City of'	, intMasterId =	4600621
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51510'	, strLocalityZipCode =	'22311'	, strLocalityName =	'Alexandria, City of'	, intMasterId =	4600622
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51510'	, strLocalityZipCode =	'22312'	, strLocalityName =	'Alexandria, City of'	, intMasterId =	4600623
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51510'	, strLocalityZipCode =	'22314'	, strLocalityName =	'Alexandria, City of'	, intMasterId =	4600624
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51510'	, strLocalityZipCode =	'22331'	, strLocalityName =	'Alexandria, City Of'	, intMasterId =	4600625
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51510'	, strLocalityZipCode =	'22332'	, strLocalityName =	'Alexandria, City of'	, intMasterId =	4600626
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51005'	, strLocalityZipCode =	'24085'	, strLocalityName =	'Alleghany County'	, intMasterId =	4600627
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51005'	, strLocalityZipCode =	'24422'	, strLocalityName =	'Alleghany County'	, intMasterId =	4600628
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51005'	, strLocalityZipCode =	'24426'	, strLocalityName =	'Alleghany County'	, intMasterId =	4600629
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51005'	, strLocalityZipCode =	'24445'	, strLocalityName =	'Alleghany County'	, intMasterId =	4600630
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51005'	, strLocalityZipCode =	'24448'	, strLocalityName =	'Alleghany County'	, intMasterId =	4600631
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51005'	, strLocalityZipCode =	'24457'	, strLocalityName =	'Alleghany County'	, intMasterId =	4600632
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51005'	, strLocalityZipCode =	'24474'	, strLocalityName =	'Alleghany County'	, intMasterId =	4600633
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51007'	, strLocalityZipCode =	'23002'	, strLocalityName =	'Amelia County'	, intMasterId =	4600634
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51007'	, strLocalityZipCode =	'23083'	, strLocalityName =	'Amelia County'	, intMasterId =	4600635
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51007'	, strLocalityZipCode =	'23105'	, strLocalityName =	'Amelia County'	, intMasterId =	4600636
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51007'	, strLocalityZipCode =	'23833'	, strLocalityName =	'Amelia County'	, intMasterId =	4600637
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51007'	, strLocalityZipCode =	'23850'	, strLocalityName =	'Amelia County'	, intMasterId =	4600638
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51009'	, strLocalityZipCode =	'22922'	, strLocalityName =	'Amherst County'	, intMasterId =	4600639
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51009'	, strLocalityZipCode =	'22967'	, strLocalityName =	'Amherst County'	, intMasterId =	4600640
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51009'	, strLocalityZipCode =	'24483'	, strLocalityName =	'Amherst County'	, intMasterId =	4600641
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51009'	, strLocalityZipCode =	'24521'	, strLocalityName =	'Amherst County'	, intMasterId =	4600642
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51009'	, strLocalityZipCode =	'24526'	, strLocalityName =	'Amherst County'	, intMasterId =	4600643
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51009'	, strLocalityZipCode =	'24533'	, strLocalityName =	'Amherst County'	, intMasterId =	4600644
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51009'	, strLocalityZipCode =	'24553'	, strLocalityName =	'Amherst County'	, intMasterId =	4600645
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51009'	, strLocalityZipCode =	'24572'	, strLocalityName =	'Amherst County'	, intMasterId =	4600646
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51009'	, strLocalityZipCode =	'24574'	, strLocalityName =	'Amherst County'	, intMasterId =	4600647
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51009'	, strLocalityZipCode =	'24595'	, strLocalityName =	'Amherst County'	, intMasterId =	4600648
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51011'	, strLocalityZipCode =	'23939'	, strLocalityName =	'Appomattox County'	, intMasterId =	4600649
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51011'	, strLocalityZipCode =	'23958'	, strLocalityName =	'Appomattox County'	, intMasterId =	4600650
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51011'	, strLocalityZipCode =	'23963'	, strLocalityName =	'Appomattox County'	, intMasterId =	4600651
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51011'	, strLocalityZipCode =	'24522'	, strLocalityName =	'Appomattox County'	, intMasterId =	4600652
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51011'	, strLocalityZipCode =	'24538'	, strLocalityName =	'Appomattox County'	, intMasterId =	4600653
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51011'	, strLocalityZipCode =	'24553'	, strLocalityName =	'Appomattox County'	, intMasterId =	4600654
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51011'	, strLocalityZipCode =	'24593'	, strLocalityName =	'Appomattox County'	, intMasterId =	4600655
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51013'	, strLocalityZipCode =	'22101'	, strLocalityName =	'Arlington County'	, intMasterId =	4600656
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51013'	, strLocalityZipCode =	'22201'	, strLocalityName =	'Arlington County'	, intMasterId =	4600657
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51013'	, strLocalityZipCode =	'22202'	, strLocalityName =	'Arlington County'	, intMasterId =	4600658
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51013'	, strLocalityZipCode =	'22203'	, strLocalityName =	'Arlington County'	, intMasterId =	4600659
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51013'	, strLocalityZipCode =	'22204'	, strLocalityName =	'Arlington County'	, intMasterId =	4600660
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51013'	, strLocalityZipCode =	'22205'	, strLocalityName =	'Arlington County'	, intMasterId =	4600661
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51013'	, strLocalityZipCode =	'22206'	, strLocalityName =	'Arlington County'	, intMasterId =	4600662
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51013'	, strLocalityZipCode =	'22207'	, strLocalityName =	'Arlington County'	, intMasterId =	4600663
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51013'	, strLocalityZipCode =	'22209'	, strLocalityName =	'Arlington County'	, intMasterId =	4600664
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51013'	, strLocalityZipCode =	'22211'	, strLocalityName =	'Arlington County'	, intMasterId =	4600665
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51013'	, strLocalityZipCode =	'22213'	, strLocalityName =	'Arlington County'	, intMasterId =	4600666
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51013'	, strLocalityZipCode =	'22214'	, strLocalityName =	'Arlington County'	, intMasterId =	4600667
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'22812'	, strLocalityName =	'Augusta County'	, intMasterId =	4600668
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'22841'	, strLocalityName =	'Augusta County'	, intMasterId =	4600669
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'22843'	, strLocalityName =	'Augusta County'	, intMasterId =	4600670
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'22920'	, strLocalityName =	'Augusta County'	, intMasterId =	4600671
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'22939'	, strLocalityName =	'Augusta County'	, intMasterId =	4600672
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'22952'	, strLocalityName =	'Augusta County'	, intMasterId =	4600673
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'22980'	, strLocalityName =	'Augusta County'	, intMasterId =	4600674
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'24401'	, strLocalityName =	'Augusta County'	, intMasterId =	4600675
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'24411'	, strLocalityName =	'Augusta County'	, intMasterId =	4600676
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'24421'	, strLocalityName =	'Augusta County'	, intMasterId =	4600677
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'24430'	, strLocalityName =	'Augusta County'	, intMasterId =	4600678
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'24431'	, strLocalityName =	'Augusta County'	, intMasterId =	4600679
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'24432'	, strLocalityName =	'Augusta County'	, intMasterId =	4600680
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'24437'	, strLocalityName =	'Augusta County'	, intMasterId =	4600681
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'24439'	, strLocalityName =	'Augusta County'	, intMasterId =	4600682
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'24440'	, strLocalityName =	'Augusta County'	, intMasterId =	4600683
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'24441'	, strLocalityName =	'Augusta County'	, intMasterId =	4600684
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'24459'	, strLocalityName =	'Augusta County'	, intMasterId =	4600685
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'24463'	, strLocalityName =	'Augusta County'	, intMasterId =	4600686
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'24467'	, strLocalityName =	'Augusta County'	, intMasterId =	4600687
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'24472'	, strLocalityName =	'Augusta County'	, intMasterId =	4600688
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'24477'	, strLocalityName =	'Augusta County'	, intMasterId =	4600689
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'24479'	, strLocalityName =	'Augusta County'	, intMasterId =	4600690
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'24482'	, strLocalityName =	'Augusta County'	, intMasterId =	4600691
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'24485'	, strLocalityName =	'Augusta County'	, intMasterId =	4600692
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51015'	, strLocalityZipCode =	'24486'	, strLocalityName =	'Augusta County'	, intMasterId =	4600693
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51017'	, strLocalityZipCode =	'24412'	, strLocalityName =	'Bath County'	, intMasterId =	4600694
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51017'	, strLocalityZipCode =	'24445'	, strLocalityName =	'Bath County'	, intMasterId =	4600695
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51017'	, strLocalityZipCode =	'24460'	, strLocalityName =	'Bath County'	, intMasterId =	4600696
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51017'	, strLocalityZipCode =	'24484'	, strLocalityName =	'Bath County'	, intMasterId =	4600697
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51017'	, strLocalityZipCode =	'24487'	, strLocalityName =	'Bath County'	, intMasterId =	4600698
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51019'	, strLocalityZipCode =	'24064'	, strLocalityName =	'Bedford County'	, intMasterId =	4600699
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51019'	, strLocalityZipCode =	'24095'	, strLocalityName =	'Bedford County'	, intMasterId =	4600700
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51019'	, strLocalityZipCode =	'24101'	, strLocalityName =	'Bedford County'	, intMasterId =	4600701
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51019'	, strLocalityZipCode =	'24104'	, strLocalityName =	'Bedford County'	, intMasterId =	4600702
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51019'	, strLocalityZipCode =	'24121'	, strLocalityName =	'Bedford County'	, intMasterId =	4600703
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51019'	, strLocalityZipCode =	'24122'	, strLocalityName =	'Bedford County'	, intMasterId =	4600704
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51019'	, strLocalityZipCode =	'24139'	, strLocalityName =	'Bedford County'	, intMasterId =	4600705
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51019'	, strLocalityZipCode =	'24174'	, strLocalityName =	'Bedford County'	, intMasterId =	4600706
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51019'	, strLocalityZipCode =	'24178'	, strLocalityName =	'Bedford County'	, intMasterId =	4600707
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51019'	, strLocalityZipCode =	'24179'	, strLocalityName =	'Bedford County'	, intMasterId =	4600708
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51019'	, strLocalityZipCode =	'24502'	, strLocalityName =	'Bedford County'	, intMasterId =	4600709
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51019'	, strLocalityZipCode =	'24503'	, strLocalityName =	'Bedford County'	, intMasterId =	4600710
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51019'	, strLocalityZipCode =	'24523'	, strLocalityName =	'Bedford County'	, intMasterId =	4600711
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51019'	, strLocalityZipCode =	'24526'	, strLocalityName =	'Bedford County'	, intMasterId =	4600712
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51019'	, strLocalityZipCode =	'24536'	, strLocalityName =	'Bedford County'	, intMasterId =	4600713
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51019'	, strLocalityZipCode =	'24550'	, strLocalityName =	'Bedford County'	, intMasterId =	4600714
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51019'	, strLocalityZipCode =	'24551'	, strLocalityName =	'Bedford County'	, intMasterId =	4600715
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51019'	, strLocalityZipCode =	'24556'	, strLocalityName =	'Bedford County'	, intMasterId =	4600716
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51019'	, strLocalityZipCode =	'24570'	, strLocalityName =	'Bedford County'	, intMasterId =	4600717
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51019'	, strLocalityZipCode =	'24571'	, strLocalityName =	'Bedford County'	, intMasterId =	4600718
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51021'	, strLocalityZipCode =	'24084'	, strLocalityName =	'Bland County'	, intMasterId =	4600719
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51021'	, strLocalityZipCode =	'24134'	, strLocalityName =	'Bland County'	, intMasterId =	4600720
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51021'	, strLocalityZipCode =	'24314'	, strLocalityName =	'Bland County'	, intMasterId =	4600721
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51021'	, strLocalityZipCode =	'24315'	, strLocalityName =	'Bland County'	, intMasterId =	4600722
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51021'	, strLocalityZipCode =	'24318'	, strLocalityName =	'Bland County'	, intMasterId =	4600723
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51021'	, strLocalityZipCode =	'24366'	, strLocalityName =	'Bland County'	, intMasterId =	4600724
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51023'	, strLocalityZipCode =	'24012'	, strLocalityName =	'Botetourt County'	, intMasterId =	4600725
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51023'	, strLocalityZipCode =	'24019'	, strLocalityName =	'Botetourt County'	, intMasterId =	4600726
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51023'	, strLocalityZipCode =	'24064'	, strLocalityName =	'Botetourt County'	, intMasterId =	4600727
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51023'	, strLocalityZipCode =	'24066'	, strLocalityName =	'Botetourt County'	, intMasterId =	4600728
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51023'	, strLocalityZipCode =	'24077'	, strLocalityName =	'Botetourt County'	, intMasterId =	4600729
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51023'	, strLocalityZipCode =	'24083'	, strLocalityName =	'Botetourt County'	, intMasterId =	4600730
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51023'	, strLocalityZipCode =	'24085'	, strLocalityName =	'Botetourt County'	, intMasterId =	4600731
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51023'	, strLocalityZipCode =	'24090'	, strLocalityName =	'Botetourt County'	, intMasterId =	4600732
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51023'	, strLocalityZipCode =	'24130'	, strLocalityName =	'Botetourt County'	, intMasterId =	4600733
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51023'	, strLocalityZipCode =	'24153'	, strLocalityName =	'Botetourt County'	, intMasterId =	4600734
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51023'	, strLocalityZipCode =	'24175'	, strLocalityName =	'Botetourt County'	, intMasterId =	4600735
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51023'	, strLocalityZipCode =	'24438'	, strLocalityName =	'Botetourt County'	, intMasterId =	4600736
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51023'	, strLocalityZipCode =	'24579'	, strLocalityName =	'Botetourt County'	, intMasterId =	4600737
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51520'	, strLocalityZipCode =	'24201'	, strLocalityName =	'Bristol, City of'	, intMasterId =	4600738
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51520'	, strLocalityZipCode =	'24202'	, strLocalityName =	'Bristol, City of'	, intMasterId =	4600739
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51025'	, strLocalityZipCode =	'23821'	, strLocalityName =	'Brunswick County'	, intMasterId =	4600740
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51025'	, strLocalityZipCode =	'23824'	, strLocalityName =	'Brunswick County'	, intMasterId =	4600741
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51025'	, strLocalityZipCode =	'23843'	, strLocalityName =	'Brunswick County'	, intMasterId =	4600742
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51025'	, strLocalityZipCode =	'23845'	, strLocalityName =	'Brunswick County'	, intMasterId =	4600743
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51025'	, strLocalityZipCode =	'23847'	, strLocalityName =	'Brunswick County'	, intMasterId =	4600744
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51025'	, strLocalityZipCode =	'23856'	, strLocalityName =	'Brunswick County'	, intMasterId =	4600745
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51025'	, strLocalityZipCode =	'23857'	, strLocalityName =	'Brunswick County'	, intMasterId =	4600746
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51025'	, strLocalityZipCode =	'23868'	, strLocalityName =	'Brunswick County'	, intMasterId =	4600747
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51025'	, strLocalityZipCode =	'23873'	, strLocalityName =	'Brunswick County'	, intMasterId =	4600748
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51025'	, strLocalityZipCode =	'23876'	, strLocalityName =	'Brunswick County'	, intMasterId =	4600749
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51025'	, strLocalityZipCode =	'23887'	, strLocalityName =	'Brunswick County'	, intMasterId =	4600750
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51025'	, strLocalityZipCode =	'23889'	, strLocalityName =	'Brunswick County'	, intMasterId =	4600751
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51025'	, strLocalityZipCode =	'23893'	, strLocalityName =	'Brunswick County'	, intMasterId =	4600752
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51025'	, strLocalityZipCode =	'23919'	, strLocalityName =	'Brunswick County'	, intMasterId =	4600753
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51025'	, strLocalityZipCode =	'23920'	, strLocalityName =	'Brunswick County'	, intMasterId =	4600754
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51025'	, strLocalityZipCode =	'23938'	, strLocalityName =	'Brunswick County'	, intMasterId =	4600755
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51025'	, strLocalityZipCode =	'23950'	, strLocalityName =	'Brunswick County'	, intMasterId =	4600756
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51027'	, strLocalityZipCode =	'24239'	, strLocalityName =	'Buchanan County'	, intMasterId =	4600757
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51027'	, strLocalityZipCode =	'24256'	, strLocalityName =	'Buchanan County'	, intMasterId =	4600758
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51027'	, strLocalityZipCode =	'24603'	, strLocalityName =	'Buchanan County'	, intMasterId =	4600759
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51027'	, strLocalityZipCode =	'24607'	, strLocalityName =	'Buchanan County'	, intMasterId =	4600760
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51027'	, strLocalityZipCode =	'24614'	, strLocalityName =	'Buchanan County'	, intMasterId =	4600761
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51027'	, strLocalityZipCode =	'24620'	, strLocalityName =	'Buchanan County'	, intMasterId =	4600762
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51027'	, strLocalityZipCode =	'24622'	, strLocalityName =	'Buchanan County'	, intMasterId =	4600763
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51027'	, strLocalityZipCode =	'24624'	, strLocalityName =	'Buchanan County'	, intMasterId =	4600764
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51027'	, strLocalityZipCode =	'24627'	, strLocalityName =	'Buchanan County'	, intMasterId =	4600765
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51027'	, strLocalityZipCode =	'24628'	, strLocalityName =	'Buchanan County'	, intMasterId =	4600766
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51027'	, strLocalityZipCode =	'24631'	, strLocalityName =	'Buchanan County'	, intMasterId =	4600767
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51027'	, strLocalityZipCode =	'24634'	, strLocalityName =	'Buchanan County'	, intMasterId =	4600768
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51027'	, strLocalityZipCode =	'24639'	, strLocalityName =	'Buchanan County'	, intMasterId =	4600769
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51027'	, strLocalityZipCode =	'24646'	, strLocalityName =	'Buchanan County'	, intMasterId =	4600770
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51027'	, strLocalityZipCode =	'24647'	, strLocalityName =	'Buchanan County'	, intMasterId =	4600771
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51027'	, strLocalityZipCode =	'24656'	, strLocalityName =	'Buchanan County'	, intMasterId =	4600772
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51027'	, strLocalityZipCode =	'24657'	, strLocalityName =	'Buchanan County'	, intMasterId =	4600773
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51027'	, strLocalityZipCode =	'24658'	, strLocalityName =	'Buchanan County'	, intMasterId =	4600774
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51029'	, strLocalityZipCode =	'23004'	, strLocalityName =	'Buckingham County'	, intMasterId =	4600775
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51029'	, strLocalityZipCode =	'23040'	, strLocalityName =	'Buckingham County'	, intMasterId =	4600776
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51029'	, strLocalityZipCode =	'23123'	, strLocalityName =	'Buckingham County'	, intMasterId =	4600777
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51029'	, strLocalityZipCode =	'23901'	, strLocalityName =	'Buckingham County'	, intMasterId =	4600778
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51029'	, strLocalityZipCode =	'23921'	, strLocalityName =	'Buckingham County'	, intMasterId =	4600779
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51029'	, strLocalityZipCode =	'23936'	, strLocalityName =	'Buckingham County'	, intMasterId =	4600780
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51029'	, strLocalityZipCode =	'24522'	, strLocalityName =	'Buckingham County'	, intMasterId =	4600781
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51029'	, strLocalityZipCode =	'24528'	, strLocalityName =	'Buckingham County'	, intMasterId =	4600782
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51029'	, strLocalityZipCode =	'24562'	, strLocalityName =	'Buckingham County'	, intMasterId =	4600783
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51029'	, strLocalityZipCode =	'24590'	, strLocalityName =	'Buckingham County'	, intMasterId =	4600784
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51530'	, strLocalityZipCode =	'24416'	, strLocalityName =	'Buena Vista, City of'	, intMasterId =	4600785
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51031'	, strLocalityZipCode =	'23963'	, strLocalityName =	'Campbell County'	, intMasterId =	4600786
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51031'	, strLocalityZipCode =	'24501'	, strLocalityName =	'Campbell County'	, intMasterId =	4600787
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51031'	, strLocalityZipCode =	'24502'	, strLocalityName =	'Campbell County'	, intMasterId =	4600788
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51031'	, strLocalityZipCode =	'24504'	, strLocalityName =	'Campbell County'	, intMasterId =	4600789
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51031'	, strLocalityZipCode =	'24517'	, strLocalityName =	'Campbell County'	, intMasterId =	4600790
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51031'	, strLocalityZipCode =	'24528'	, strLocalityName =	'Campbell County'	, intMasterId =	4600791
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51031'	, strLocalityZipCode =	'24538'	, strLocalityName =	'Campbell County'	, intMasterId =	4600792
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51031'	, strLocalityZipCode =	'24550'	, strLocalityName =	'Campbell County'	, intMasterId =	4600793
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51031'	, strLocalityZipCode =	'24551'	, strLocalityName =	'Campbell County'	, intMasterId =	4600794
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51031'	, strLocalityZipCode =	'24554'	, strLocalityName =	'Campbell County'	, intMasterId =	4600795
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51031'	, strLocalityZipCode =	'24569'	, strLocalityName =	'Campbell County'	, intMasterId =	4600796
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51031'	, strLocalityZipCode =	'24571'	, strLocalityName =	'Campbell County'	, intMasterId =	4600797
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51031'	, strLocalityZipCode =	'24576'	, strLocalityName =	'Campbell County'	, intMasterId =	4600798
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51031'	, strLocalityZipCode =	'24588'	, strLocalityName =	'Campbell County'	, intMasterId =	4600799
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51033'	, strLocalityZipCode =	'22408'	, strLocalityName =	'Caroline County'	, intMasterId =	4600800
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51033'	, strLocalityZipCode =	'22427'	, strLocalityName =	'Caroline County'	, intMasterId =	4600801
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51033'	, strLocalityZipCode =	'22428'	, strLocalityName =	'Caroline County'	, intMasterId =	4600802
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51033'	, strLocalityZipCode =	'22436'	, strLocalityName =	'Caroline County'	, intMasterId =	4600803
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51033'	, strLocalityZipCode =	'22438'	, strLocalityName =	'Caroline County'	, intMasterId =	4600804
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51033'	, strLocalityZipCode =	'22446'	, strLocalityName =	'Caroline County'	, intMasterId =	4600805
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51033'	, strLocalityZipCode =	'22501'	, strLocalityName =	'Caroline County'	, intMasterId =	4600806
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51033'	, strLocalityZipCode =	'22514'	, strLocalityName =	'Caroline County'	, intMasterId =	4600807
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51033'	, strLocalityZipCode =	'22535'	, strLocalityName =	'Caroline County'	, intMasterId =	4600808
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51033'	, strLocalityZipCode =	'22538'	, strLocalityName =	'Caroline County'	, intMasterId =	4600809
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51033'	, strLocalityZipCode =	'22546'	, strLocalityName =	'Caroline County'	, intMasterId =	4600810
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51033'	, strLocalityZipCode =	'22552'	, strLocalityName =	'Caroline County'	, intMasterId =	4600811
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51033'	, strLocalityZipCode =	'22580'	, strLocalityName =	'Caroline County'	, intMasterId =	4600812
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51033'	, strLocalityZipCode =	'23015'	, strLocalityName =	'Caroline County'	, intMasterId =	4600813
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51033'	, strLocalityZipCode =	'23047'	, strLocalityName =	'Caroline County'	, intMasterId =	4600814
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51033'	, strLocalityZipCode =	'23069'	, strLocalityName =	'Caroline County'	, intMasterId =	4600815
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51035'	, strLocalityZipCode =	'24053'	, strLocalityName =	'Carroll County'	, intMasterId =	4600816
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51035'	, strLocalityZipCode =	'24105'	, strLocalityName =	'Carroll County'	, intMasterId =	4600817
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51035'	, strLocalityZipCode =	'24120'	, strLocalityName =	'Carroll County'	, intMasterId =	4600818
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51035'	, strLocalityZipCode =	'24312'	, strLocalityName =	'Carroll County'	, intMasterId =	4600819
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51035'	, strLocalityZipCode =	'24317'	, strLocalityName =	'Carroll County'	, intMasterId =	4600820
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51035'	, strLocalityZipCode =	'24325'	, strLocalityName =	'Carroll County'	, intMasterId =	4600821
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51035'	, strLocalityZipCode =	'24328'	, strLocalityName =	'Carroll County'	, intMasterId =	4600822
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51035'	, strLocalityZipCode =	'24330'	, strLocalityName =	'Carroll County'	, intMasterId =	4600823
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51035'	, strLocalityZipCode =	'24333'	, strLocalityName =	'Carroll County'	, intMasterId =	4600824
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51035'	, strLocalityZipCode =	'24343'	, strLocalityName =	'Carroll County'	, intMasterId =	4600825
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51035'	, strLocalityZipCode =	'24347'	, strLocalityName =	'Carroll County'	, intMasterId =	4600826
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51035'	, strLocalityZipCode =	'24350'	, strLocalityName =	'Carroll County'	, intMasterId =	4600827
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51035'	, strLocalityZipCode =	'24351'	, strLocalityName =	'Carroll County'	, intMasterId =	4600828
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51035'	, strLocalityZipCode =	'24352'	, strLocalityName =	'Carroll County'	, intMasterId =	4600829
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51035'	, strLocalityZipCode =	'24380'	, strLocalityName =	'Carroll County'	, intMasterId =	4600830
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51035'	, strLocalityZipCode =	'24381'	, strLocalityName =	'Carroll County'	, intMasterId =	4600831
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51036'	, strLocalityZipCode =	'23030'	, strLocalityName =	'Charles City County'	, intMasterId =	4600832
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51036'	, strLocalityZipCode =	'23140'	, strLocalityName =	'Charles City County'	, intMasterId =	4600833
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51036'	, strLocalityZipCode =	'23147'	, strLocalityName =	'Charles City County'	, intMasterId =	4600834
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51036'	, strLocalityZipCode =	'23185'	, strLocalityName =	'Charles City County'	, intMasterId =	4600835
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51037'	, strLocalityZipCode =	'23923'	, strLocalityName =	'Charlotte County'	, intMasterId =	4600836
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51037'	, strLocalityZipCode =	'23924'	, strLocalityName =	'Charlotte County'	, intMasterId =	4600837
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51037'	, strLocalityZipCode =	'23934'	, strLocalityName =	'Charlotte County'	, intMasterId =	4600838
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51037'	, strLocalityZipCode =	'23937'	, strLocalityName =	'Charlotte County'	, intMasterId =	4600839
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51037'	, strLocalityZipCode =	'23947'	, strLocalityName =	'Charlotte County'	, intMasterId =	4600840
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51037'	, strLocalityZipCode =	'23958'	, strLocalityName =	'Charlotte County'	, intMasterId =	4600841
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51037'	, strLocalityZipCode =	'23959'	, strLocalityName =	'Charlotte County'	, intMasterId =	4600842
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51037'	, strLocalityZipCode =	'23962'	, strLocalityName =	'Charlotte County'	, intMasterId =	4600843
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51037'	, strLocalityZipCode =	'23963'	, strLocalityName =	'Charlotte County'	, intMasterId =	4600844
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51037'	, strLocalityZipCode =	'23964'	, strLocalityName =	'Charlotte County'	, intMasterId =	4600845
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51037'	, strLocalityZipCode =	'23967'	, strLocalityName =	'Charlotte County'	, intMasterId =	4600846
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51037'	, strLocalityZipCode =	'23976'	, strLocalityName =	'Charlotte County'	, intMasterId =	4600847
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51037'	, strLocalityZipCode =	'24528'	, strLocalityName =	'Charlotte County'	, intMasterId =	4600848
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51540'	, strLocalityZipCode =	'22901'	, strLocalityName =	'Charlottesville, City of'	, intMasterId =	4600849
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51540'	, strLocalityZipCode =	'22902'	, strLocalityName =	'Charlottesville, City of'	, intMasterId =	4600850
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51540'	, strLocalityZipCode =	'22903'	, strLocalityName =	'Charlottesville, City of'	, intMasterId =	4600851
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51550'	, strLocalityZipCode =	'23320'	, strLocalityName =	'Chesapeake, City of'	, intMasterId =	4600852
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51550'	, strLocalityZipCode =	'23321'	, strLocalityName =	'Chesapeake, City of'	, intMasterId =	4600853
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51550'	, strLocalityZipCode =	'23322'	, strLocalityName =	'Chesapeake, City of'	, intMasterId =	4600854
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51550'	, strLocalityZipCode =	'23323'	, strLocalityName =	'Chesapeake, City of'	, intMasterId =	4600855
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51550'	, strLocalityZipCode =	'23324'	, strLocalityName =	'Chesapeake, City of'	, intMasterId =	4600856
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51550'	, strLocalityZipCode =	'23325'	, strLocalityName =	'Chesapeake, City of'	, intMasterId =	4600857
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51550'	, strLocalityZipCode =	'23326'	, strLocalityName =	'Chesapeake, City of'	, intMasterId =	4600858
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51550'	, strLocalityZipCode =	'23702'	, strLocalityName =	'Chesapeake, City of'	, intMasterId =	4600859
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51041'	, strLocalityZipCode =	'23112'	, strLocalityName =	'Chesterfield County'	, intMasterId =	4600860
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51041'	, strLocalityZipCode =	'23113'	, strLocalityName =	'Chesterfield County'	, intMasterId =	4600861
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51041'	, strLocalityZipCode =	'23114'	, strLocalityName =	'Chesterfield County'	, intMasterId =	4600862
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51041'	, strLocalityZipCode =	'23120'	, strLocalityName =	'Chesterfield County'	, intMasterId =	4600863
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51041'	, strLocalityZipCode =	'23224'	, strLocalityName =	'Chesterfield County'	, intMasterId =	4600864
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51041'	, strLocalityZipCode =	'23225'	, strLocalityName =	'Chesterfield County'	, intMasterId =	4600865
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51041'	, strLocalityZipCode =	'23234'	, strLocalityName =	'Chesterfield County'	, intMasterId =	4600866
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51041'	, strLocalityZipCode =	'23235'	, strLocalityName =	'Chesterfield County'	, intMasterId =	4600867
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51041'	, strLocalityZipCode =	'23236'	, strLocalityName =	'Chesterfield County'	, intMasterId =	4600868
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51041'	, strLocalityZipCode =	'23237'	, strLocalityName =	'Chesterfield County'	, intMasterId =	4600869
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51041'	, strLocalityZipCode =	'23297'	, strLocalityName =	'Chesterfield County'	, intMasterId =	4600870
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51041'	, strLocalityZipCode =	'23803'	, strLocalityName =	'Chesterfield County'	, intMasterId =	4600871
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51041'	, strLocalityZipCode =	'23831'	, strLocalityName =	'Chesterfield County'	, intMasterId =	4600872
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51041'	, strLocalityZipCode =	'23832'	, strLocalityName =	'Chesterfield County'	, intMasterId =	4600873
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51041'	, strLocalityZipCode =	'23834'	, strLocalityName =	'Chesterfield County'	, intMasterId =	4600874
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51041'	, strLocalityZipCode =	'23836'	, strLocalityName =	'Chesterfield County'	, intMasterId =	4600875
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51041'	, strLocalityZipCode =	'23838'	, strLocalityName =	'Chesterfield County'	, intMasterId =	4600876
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51043'	, strLocalityZipCode =	'20130'	, strLocalityName =	'Clarke County'	, intMasterId =	4600877
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51043'	, strLocalityZipCode =	'20135'	, strLocalityName =	'Clarke County'	, intMasterId =	4600878
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51043'	, strLocalityZipCode =	'22611'	, strLocalityName =	'Clarke County'	, intMasterId =	4600879
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51043'	, strLocalityZipCode =	'22620'	, strLocalityName =	'Clarke County'	, intMasterId =	4600880
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51043'	, strLocalityZipCode =	'22646'	, strLocalityName =	'Clarke County'	, intMasterId =	4600881
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51043'	, strLocalityZipCode =	'22663'	, strLocalityName =	'Clarke County'	, intMasterId =	4600882
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51570'	, strLocalityZipCode =	'23834'	, strLocalityName =	'Colonial Heights, City Of'	, intMasterId =	4600883
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51580'	, strLocalityZipCode =	'24426'	, strLocalityName =	'Covington, City of'	, intMasterId =	4600884
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51045'	, strLocalityZipCode =	'24070'	, strLocalityName =	'Craig County'	, intMasterId =	4600885
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51045'	, strLocalityZipCode =	'24127'	, strLocalityName =	'Craig County'	, intMasterId =	4600886
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51045'	, strLocalityZipCode =	'24128'	, strLocalityName =	'Craig County'	, intMasterId =	4600887
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51045'	, strLocalityZipCode =	'24131'	, strLocalityName =	'Craig County'	, intMasterId =	4600888
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51047'	, strLocalityZipCode =	'20106'	, strLocalityName =	'Culpeper County'	, intMasterId =	4600889
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51047'	, strLocalityZipCode =	'20186'	, strLocalityName =	'Culpeper County'	, intMasterId =	4600890
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51047'	, strLocalityZipCode =	'22407'	, strLocalityName =	'Culpeper County'	, intMasterId =	4600891
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51047'	, strLocalityZipCode =	'22701'	, strLocalityName =	'Culpeper County'	, intMasterId =	4600892
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51047'	, strLocalityZipCode =	'22713'	, strLocalityName =	'Culpeper County'	, intMasterId =	4600893
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51047'	, strLocalityZipCode =	'22714'	, strLocalityName =	'Culpeper County'	, intMasterId =	4600894
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51047'	, strLocalityZipCode =	'22716'	, strLocalityName =	'Culpeper County'	, intMasterId =	4600895
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51047'	, strLocalityZipCode =	'22718'	, strLocalityName =	'Culpeper County'	, intMasterId =	4600896
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51047'	, strLocalityZipCode =	'22724'	, strLocalityName =	'Culpeper County'	, intMasterId =	4600897
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51047'	, strLocalityZipCode =	'22726'	, strLocalityName =	'Culpeper County'	, intMasterId =	4600898
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51047'	, strLocalityZipCode =	'22729'	, strLocalityName =	'Culpeper County'	, intMasterId =	4600899
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51047'	, strLocalityZipCode =	'22733'	, strLocalityName =	'Culpeper County'	, intMasterId =	4600900
							
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51047'	, strLocalityZipCode =	'22734'	, strLocalityName =	'Culpeper County'	, intMasterId =	4600901
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51047'	, strLocalityZipCode =	'22735'	, strLocalityName =	'Culpeper County'	, intMasterId =	4600902
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51047'	, strLocalityZipCode =	'22736'	, strLocalityName =	'Culpeper County'	, intMasterId =	4600903
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51047'	, strLocalityZipCode =	'22737'	, strLocalityName =	'Culpeper County'	, intMasterId =	4600904
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51047'	, strLocalityZipCode =	'22740'	, strLocalityName =	'Culpeper County'	, intMasterId =	4600905
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51047'	, strLocalityZipCode =	'22741'	, strLocalityName =	'Culpeper County'	, intMasterId =	4600906
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51047'	, strLocalityZipCode =	'22746'	, strLocalityName =	'Culpeper County'	, intMasterId =	4600907
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51049'	, strLocalityZipCode =	'23027'	, strLocalityName =	'Cumberland County'	, intMasterId =	4600908
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51049'	, strLocalityZipCode =	'23038'	, strLocalityName =	'Cumberland County'	, intMasterId =	4600909
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51049'	, strLocalityZipCode =	'23040'	, strLocalityName =	'Cumberland County'	, intMasterId =	4600910
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51049'	, strLocalityZipCode =	'23123'	, strLocalityName =	'Cumberland County'	, intMasterId =	4600911
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51049'	, strLocalityZipCode =	'23139'	, strLocalityName =	'Cumberland County'	, intMasterId =	4600912
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51049'	, strLocalityZipCode =	'23901'	, strLocalityName =	'Cumberland County'	, intMasterId =	4600913
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51049'	, strLocalityZipCode =	'23936'	, strLocalityName =	'Cumberland County'	, intMasterId =	4600914
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51590'	, strLocalityZipCode =	'24540'	, strLocalityName =	'Danville, City of'	, intMasterId =	4600915
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51590'	, strLocalityZipCode =	'24541'	, strLocalityName =	'Danville, City of'	, intMasterId =	4600916
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51590'	, strLocalityZipCode =	'24543'	, strLocalityName =	'Danville, City of'	, intMasterId =	4600917
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51051'	, strLocalityZipCode =	'24217'	, strLocalityName =	'Dickenson County'	, intMasterId =	4600918
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51051'	, strLocalityZipCode =	'24220'	, strLocalityName =	'Dickenson County'	, intMasterId =	4600919
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51051'	, strLocalityZipCode =	'24225'	, strLocalityName =	'Dickenson County'	, intMasterId =	4600920
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51051'	, strLocalityZipCode =	'24226'	, strLocalityName =	'Dickenson County'	, intMasterId =	4600921
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51051'	, strLocalityZipCode =	'24228'	, strLocalityName =	'Dickenson County'	, intMasterId =	4600922
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51051'	, strLocalityZipCode =	'24230'	, strLocalityName =	'Dickenson County'	, intMasterId =	4600923
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51051'	, strLocalityZipCode =	'24237'	, strLocalityName =	'Dickenson County'	, intMasterId =	4600924
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51051'	, strLocalityZipCode =	'24256'	, strLocalityName =	'Dickenson County'	, intMasterId =	4600925
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51051'	, strLocalityZipCode =	'24269'	, strLocalityName =	'Dickenson County'	, intMasterId =	4600926
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51051'	, strLocalityZipCode =	'24272'	, strLocalityName =	'Dickenson County'	, intMasterId =	4600927
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51051'	, strLocalityZipCode =	'24283'	, strLocalityName =	'Dickenson County'	, intMasterId =	4600928
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51051'	, strLocalityZipCode =	'24293'	, strLocalityName =	'Dickenson County'	, intMasterId =	4600929
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51051'	, strLocalityZipCode =	'24607'	, strLocalityName =	'Dickenson County'	, intMasterId =	4600930
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51053'	, strLocalityZipCode =	'23803'	, strLocalityName =	'Dinwiddie County'	, intMasterId =	4600931
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51053'	, strLocalityZipCode =	'23805'	, strLocalityName =	'Dinwiddie County'	, intMasterId =	4600932
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51053'	, strLocalityZipCode =	'23822'	, strLocalityName =	'Dinwiddie County'	, intMasterId =	4600933
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51053'	, strLocalityZipCode =	'23824'	, strLocalityName =	'Dinwiddie County'	, intMasterId =	4600934
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51053'	, strLocalityZipCode =	'23830'	, strLocalityName =	'Dinwiddie County'	, intMasterId =	4600935
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51053'	, strLocalityZipCode =	'23833'	, strLocalityName =	'Dinwiddie County'	, intMasterId =	4600936
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51053'	, strLocalityZipCode =	'23840'	, strLocalityName =	'Dinwiddie County'	, intMasterId =	4600937
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51053'	, strLocalityZipCode =	'23841'	, strLocalityName =	'Dinwiddie County'	, intMasterId =	4600938
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51053'	, strLocalityZipCode =	'23850'	, strLocalityName =	'Dinwiddie County'	, intMasterId =	4600939
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51053'	, strLocalityZipCode =	'23872'	, strLocalityName =	'Dinwiddie County'	, intMasterId =	4600940
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51053'	, strLocalityZipCode =	'23882'	, strLocalityName =	'Dinwiddie County'	, intMasterId =	4600941
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51053'	, strLocalityZipCode =	'23885'	, strLocalityName =	'Dinwiddie County'	, intMasterId =	4600942
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51053'	, strLocalityZipCode =	'23894'	, strLocalityName =	'Dinwiddie County'	, intMasterId =	4600943
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51595'	, strLocalityZipCode =	'23847'	, strLocalityName =	'Emporia, City of'	, intMasterId =	4600944
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51057'	, strLocalityZipCode =	'22436'	, strLocalityName =	'Essex County'	, intMasterId =	4600945
							
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51057'	, strLocalityZipCode =	'22437'	, strLocalityName =	'Essex County'	, intMasterId =	4600946
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51057'	, strLocalityZipCode =	'22438'	, strLocalityName =	'Essex County'	, intMasterId =	4600947
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51057'	, strLocalityZipCode =	'22454'	, strLocalityName =	'Essex County'	, intMasterId =	4600948
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51057'	, strLocalityZipCode =	'22476'	, strLocalityName =	'Essex County'	, intMasterId =	4600949
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51057'	, strLocalityZipCode =	'22504'	, strLocalityName =	'Essex County'	, intMasterId =	4600950
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51057'	, strLocalityZipCode =	'22509'	, strLocalityName =	'Essex County'	, intMasterId =	4600951
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51057'	, strLocalityZipCode =	'22560'	, strLocalityName =	'Essex County'	, intMasterId =	4600952
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51057'	, strLocalityZipCode =	'23023'	, strLocalityName =	'Essex County'	, intMasterId =	4600953
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51057'	, strLocalityZipCode =	'23115'	, strLocalityName =	'Essex County'	, intMasterId =	4600954
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51057'	, strLocalityZipCode =	'23148'	, strLocalityName =	'Essex County'	, intMasterId =	4600955
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'20120'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600956
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'20121'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600957
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'20124'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600958
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'20151'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600959
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'20170'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600960
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'20171'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600961
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'20190'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600962
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'20191'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600963
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'20194'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600964
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22003'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600965
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22015'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600966
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22027'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600967
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22030'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600968
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22031'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600969
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22032'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600970
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22033'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600971
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22039'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600972
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22041'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600973
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22042'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600974
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22043'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600975
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22044'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600976
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22046'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600977
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22060'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600978
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22066'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600979
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22079'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600980
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22101'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600981
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22102'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600982
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22124'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600983
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22150'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600984
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22151'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600985
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22152'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600986
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22153'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600987
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22180'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600988
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22181'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600989
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22182'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600990
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22207'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600991
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22303'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600992
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22304'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600993
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22306'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600994
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22307'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600995
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22308'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600996
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22309'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600997
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22310'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600998
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22311'	, strLocalityName =	'Fairfax County'	, intMasterId =	4600999
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22312'	, strLocalityName =	'Fairfax County'	, intMasterId =	4601000
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51059'	, strLocalityZipCode =	'22315'	, strLocalityName =	'Fairfax County'	, intMasterId =	4601001
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51600'	, strLocalityZipCode =	'22030'	, strLocalityName =	'Fairfax, City of'	, intMasterId =	4601002
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51600'	, strLocalityZipCode =	'22031'	, strLocalityName =	'Fairfax, City of'	, intMasterId =	4601003
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51600'	, strLocalityZipCode =	'22032'	, strLocalityName =	'Fairfax, City of'	, intMasterId =	4601004
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51610'	, strLocalityZipCode =	'22042'	, strLocalityName =	'Falls Church, City of'	, intMasterId =	4601005
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51610'	, strLocalityZipCode =	'22044'	, strLocalityName =	'Falls Church, City of'	, intMasterId =	4601006
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51610'	, strLocalityZipCode =	'22046'	, strLocalityName =	'Falls Church, City of'	, intMasterId =	4601007
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'20106'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601008
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'20115'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601009
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'20116'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601010
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'20117'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601011
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'20119'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601012
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'20128'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601013
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'20130'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601014
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'20137'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601015
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'20138'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601016
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'20139'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601017
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'20140'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601018
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'20144'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601019
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'20169'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601020
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'20181'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601021
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'20184'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601022
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'20185'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601023
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'20186'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601024
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'20187'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601025
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'20188'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601026
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'20198'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601027
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'22406'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601028
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'22556'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601029
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'22639'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601030
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'22642'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601031
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'22643'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601032
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'22712'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601033
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'22720'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601034
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'22728'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601035
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'22734'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601036
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'22739'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601037
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51061'	, strLocalityZipCode =	'22742'	, strLocalityName =	'Fauquier County'	, intMasterId =	4601038
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51063'	, strLocalityZipCode =	'24072'	, strLocalityName =	'Floyd County'	, intMasterId =	4601039
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51063'	, strLocalityZipCode =	'24079'	, strLocalityName =	'Floyd County'	, intMasterId =	4601040
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51063'	, strLocalityZipCode =	'24091'	, strLocalityName =	'Floyd County'	, intMasterId =	4601041
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51063'	, strLocalityZipCode =	'24105'	, strLocalityName =	'Floyd County'	, intMasterId =	4601042
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51063'	, strLocalityZipCode =	'24120'	, strLocalityName =	'Floyd County'	, intMasterId =	4601043
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51063'	, strLocalityZipCode =	'24138'	, strLocalityName =	'Floyd County'	, intMasterId =	4601044
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51063'	, strLocalityZipCode =	'24141'	, strLocalityName =	'Floyd County'	, intMasterId =	4601045
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51063'	, strLocalityZipCode =	'24149'	, strLocalityName =	'Floyd County'	, intMasterId =	4601046
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51063'	, strLocalityZipCode =	'24162'	, strLocalityName =	'Floyd County'	, intMasterId =	4601047
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51063'	, strLocalityZipCode =	'24380'	, strLocalityName =	'Floyd County'	, intMasterId =	4601048
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51065'	, strLocalityZipCode =	'22902'	, strLocalityName =	'Fluvanna County'	, intMasterId =	4601049
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51065'	, strLocalityZipCode =	'22947'	, strLocalityName =	'Fluvanna County'	, intMasterId =	4601050
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51065'	, strLocalityZipCode =	'22963'	, strLocalityName =	'Fluvanna County'	, intMasterId =	4601051
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51065'	, strLocalityZipCode =	'22974'	, strLocalityName =	'Fluvanna County'	, intMasterId =	4601052
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51065'	, strLocalityZipCode =	'23022'	, strLocalityName =	'Fluvanna County'	, intMasterId =	4601053
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51065'	, strLocalityZipCode =	'23038'	, strLocalityName =	'Fluvanna County'	, intMasterId =	4601054
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51065'	, strLocalityZipCode =	'23055'	, strLocalityName =	'Fluvanna County'	, intMasterId =	4601055
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51065'	, strLocalityZipCode =	'23084'	, strLocalityName =	'Fluvanna County'	, intMasterId =	4601056
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51065'	, strLocalityZipCode =	'23093'	, strLocalityName =	'Fluvanna County'	, intMasterId =	4601057
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51065'	, strLocalityZipCode =	'24590'	, strLocalityName =	'Fluvanna County'	, intMasterId =	4601058
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51067'	, strLocalityZipCode =	'24055'	, strLocalityName =	'Franklin County'	, intMasterId =	4601059
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51067'	, strLocalityZipCode =	'24059'	, strLocalityName =	'Franklin County'	, intMasterId =	4601060
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51067'	, strLocalityZipCode =	'24065'	, strLocalityName =	'Franklin County'	, intMasterId =	4601061
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51067'	, strLocalityZipCode =	'24067'	, strLocalityName =	'Franklin County'	, intMasterId =	4601062
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51067'	, strLocalityZipCode =	'24079'	, strLocalityName =	'Franklin County'	, intMasterId =	4601063
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51067'	, strLocalityZipCode =	'24088'	, strLocalityName =	'Franklin County'	, intMasterId =	4601064
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51067'	, strLocalityZipCode =	'24091'	, strLocalityName =	'Franklin County'	, intMasterId =	4601065
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51067'	, strLocalityZipCode =	'24092'	, strLocalityName =	'Franklin County'	, intMasterId =	4601066
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51067'	, strLocalityZipCode =	'24101'	, strLocalityName =	'Franklin County'	, intMasterId =	4601067
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51067'	, strLocalityZipCode =	'24102'	, strLocalityName =	'Franklin County'	, intMasterId =	4601068
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51067'	, strLocalityZipCode =	'24112'	, strLocalityName =	'Franklin County'	, intMasterId =	4601069
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51067'	, strLocalityZipCode =	'24121'	, strLocalityName =	'Franklin County'	, intMasterId =	4601070
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51067'	, strLocalityZipCode =	'24137'	, strLocalityName =	'Franklin County'	, intMasterId =	4601071
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51067'	, strLocalityZipCode =	'24146'	, strLocalityName =	'Franklin County'	, intMasterId =	4601072
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51067'	, strLocalityZipCode =	'24151'	, strLocalityName =	'Franklin County'	, intMasterId =	4601073
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51067'	, strLocalityZipCode =	'24176'	, strLocalityName =	'Franklin County'	, intMasterId =	4601074
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51067'	, strLocalityZipCode =	'24184'	, strLocalityName =	'Franklin County'	, intMasterId =	4601075
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51620'	, strLocalityZipCode =	'23851'	, strLocalityName =	'Franklin, City of'	, intMasterId =	4601076
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51069'	, strLocalityZipCode =	'22602'	, strLocalityName =	'Frederick County'	, intMasterId =	4601077
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51069'	, strLocalityZipCode =	'22603'	, strLocalityName =	'Frederick County'	, intMasterId =	4601078
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51069'	, strLocalityZipCode =	'22622'	, strLocalityName =	'Frederick County'	, intMasterId =	4601079
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51069'	, strLocalityZipCode =	'22624'	, strLocalityName =	'Frederick County'	, intMasterId =	4601080
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51069'	, strLocalityZipCode =	'22625'	, strLocalityName =	'Frederick County'	, intMasterId =	4601081
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51069'	, strLocalityZipCode =	'22637'	, strLocalityName =	'Frederick County'	, intMasterId =	4601082
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51069'	, strLocalityZipCode =	'22645'	, strLocalityName =	'Frederick County'	, intMasterId =	4601083
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51069'	, strLocalityZipCode =	'22654'	, strLocalityName =	'Frederick County'	, intMasterId =	4601084
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51069'	, strLocalityZipCode =	'22655'	, strLocalityName =	'Frederick County'	, intMasterId =	4601085
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51069'	, strLocalityZipCode =	'22656'	, strLocalityName =	'Frederick County'	, intMasterId =	4601086
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51069'	, strLocalityZipCode =	'22663'	, strLocalityName =	'Frederick County'	, intMasterId =	4601087
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51630'	, strLocalityZipCode =	'22401'	, strLocalityName =	'Fredericksburg, City of'	, intMasterId =	4601088
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51630'	, strLocalityZipCode =	'22407'	, strLocalityName =	'Fredericksburg, City of'	, intMasterId =	4601089
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51640'	, strLocalityZipCode =	'24333'	, strLocalityName =	'Galax, City of'	, intMasterId =	4601090
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51071'	, strLocalityZipCode =	'24086'	, strLocalityName =	'Giles County'	, intMasterId =	4601091
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51071'	, strLocalityZipCode =	'24093'	, strLocalityName =	'Giles County'	, intMasterId =	4601092
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51071'	, strLocalityZipCode =	'24124'	, strLocalityName =	'Giles County'	, intMasterId =	4601093
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51071'	, strLocalityZipCode =	'24128'	, strLocalityName =	'Giles County'	, intMasterId =	4601094
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51071'	, strLocalityZipCode =	'24134'	, strLocalityName =	'Giles County'	, intMasterId =	4601095
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51071'	, strLocalityZipCode =	'24136'	, strLocalityName =	'Giles County'	, intMasterId =	4601096
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51071'	, strLocalityZipCode =	'24147'	, strLocalityName =	'Giles County'	, intMasterId =	4601097
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51071'	, strLocalityZipCode =	'24150'	, strLocalityName =	'Giles County'	, intMasterId =	4601098
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51071'	, strLocalityZipCode =	'24167'	, strLocalityName =	'Giles County'	, intMasterId =	4601099
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51071'	, strLocalityZipCode =	'24315'	, strLocalityName =	'Giles County'	, intMasterId =	4601100
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51073'	, strLocalityZipCode =	'23001'	, strLocalityName =	'Gloucester County'	, intMasterId =	4601101
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51073'	, strLocalityZipCode =	'23003'	, strLocalityName =	'Gloucester County'	, intMasterId =	4601102
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51073'	, strLocalityZipCode =	'23018'	, strLocalityName =	'Gloucester County'	, intMasterId =	4601103
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51073'	, strLocalityZipCode =	'23050'	, strLocalityName =	'Gloucester County'	, intMasterId =	4601104
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51073'	, strLocalityZipCode =	'23061'	, strLocalityName =	'Gloucester County'	, intMasterId =	4601105
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51073'	, strLocalityZipCode =	'23062'	, strLocalityName =	'Gloucester County'	, intMasterId =	4601106
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51073'	, strLocalityZipCode =	'23072'	, strLocalityName =	'Gloucester County'	, intMasterId =	4601107
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51073'	, strLocalityZipCode =	'23107'	, strLocalityName =	'Gloucester County'	, intMasterId =	4601108
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51073'	, strLocalityZipCode =	'23128'	, strLocalityName =	'Gloucester County'	, intMasterId =	4601109
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51073'	, strLocalityZipCode =	'23131'	, strLocalityName =	'Gloucester County'	, intMasterId =	4601110
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51073'	, strLocalityZipCode =	'23149'	, strLocalityName =	'Gloucester County'	, intMasterId =	4601111
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51073'	, strLocalityZipCode =	'23154'	, strLocalityName =	'Gloucester County'	, intMasterId =	4601112
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51073'	, strLocalityZipCode =	'23155'	, strLocalityName =	'Gloucester County'	, intMasterId =	4601113
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51073'	, strLocalityZipCode =	'23178'	, strLocalityName =	'Gloucester County'	, intMasterId =	4601114
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51073'	, strLocalityZipCode =	'23183'	, strLocalityName =	'Gloucester County'	, intMasterId =	4601115
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51073'	, strLocalityZipCode =	'23184'	, strLocalityName =	'Gloucester County'	, intMasterId =	4601116
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51073'	, strLocalityZipCode =	'23190'	, strLocalityName =	'Gloucester County'	, intMasterId =	4601117
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51075'	, strLocalityZipCode =	'23014'	, strLocalityName =	'Goochland County'	, intMasterId =	4601118
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51075'	, strLocalityZipCode =	'23038'	, strLocalityName =	'Goochland County'	, intMasterId =	4601119
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51075'	, strLocalityZipCode =	'23039'	, strLocalityName =	'Goochland County'	, intMasterId =	4601120
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51075'	, strLocalityZipCode =	'23059'	, strLocalityName =	'Goochland County'	, intMasterId =	4601121
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51075'	, strLocalityZipCode =	'23063'	, strLocalityName =	'Goochland County'	, intMasterId =	4601122
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51075'	, strLocalityZipCode =	'23065'	, strLocalityName =	'Goochland County'	, intMasterId =	4601123
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51075'	, strLocalityZipCode =	'23067'	, strLocalityName =	'Goochland County'	, intMasterId =	4601124
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51075'	, strLocalityZipCode =	'23084'	, strLocalityName =	'Goochland County'	, intMasterId =	4601125
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51075'	, strLocalityZipCode =	'23102'	, strLocalityName =	'Goochland County'	, intMasterId =	4601126
							
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51075'	, strLocalityZipCode =	'23103'	, strLocalityName =	'Goochland County'	, intMasterId =	4601127
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51075'	, strLocalityZipCode =	'23117'	, strLocalityName =	'Goochland County'	, intMasterId =	4601128
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51075'	, strLocalityZipCode =	'23129'	, strLocalityName =	'Goochland County'	, intMasterId =	4601129
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51075'	, strLocalityZipCode =	'23146'	, strLocalityName =	'Goochland County'	, intMasterId =	4601130
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51075'	, strLocalityZipCode =	'23153'	, strLocalityName =	'Goochland County'	, intMasterId =	4601131
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51075'	, strLocalityZipCode =	'23160'	, strLocalityName =	'Goochland County'	, intMasterId =	4601132
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51075'	, strLocalityZipCode =	'23233'	, strLocalityName =	'Goochland County'	, intMasterId =	4601133
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51075'	, strLocalityZipCode =	'23238'	, strLocalityName =	'Goochland County'	, intMasterId =	4601134
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51077'	, strLocalityZipCode =	'24292'	, strLocalityName =	'Grayson County'	, intMasterId =	4601135
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51077'	, strLocalityZipCode =	'24326'	, strLocalityName =	'Grayson County'	, intMasterId =	4601136
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51077'	, strLocalityZipCode =	'24330'	, strLocalityName =	'Grayson County'	, intMasterId =	4601137
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51077'	, strLocalityZipCode =	'24333'	, strLocalityName =	'Grayson County'	, intMasterId =	4601138
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51077'	, strLocalityZipCode =	'24348'	, strLocalityName =	'Grayson County'	, intMasterId =	4601139
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51077'	, strLocalityZipCode =	'24350'	, strLocalityName =	'Grayson County'	, intMasterId =	4601140
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51077'	, strLocalityZipCode =	'24363'	, strLocalityName =	'Grayson County'	, intMasterId =	4601141
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51077'	, strLocalityZipCode =	'24375'	, strLocalityName =	'Grayson County'	, intMasterId =	4601142
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51077'	, strLocalityZipCode =	'24378'	, strLocalityName =	'Grayson County'	, intMasterId =	4601143
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51079'	, strLocalityZipCode =	'22727'	, strLocalityName =	'Greene County'	, intMasterId =	4601144
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51079'	, strLocalityZipCode =	'22923'	, strLocalityName =	'Greene County'	, intMasterId =	4601145
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51079'	, strLocalityZipCode =	'22935'	, strLocalityName =	'Greene County'	, intMasterId =	4601146
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51079'	, strLocalityZipCode =	'22940'	, strLocalityName =	'Greene County'	, intMasterId =	4601147
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51079'	, strLocalityZipCode =	'22965'	, strLocalityName =	'Greene County'	, intMasterId =	4601148
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51079'	, strLocalityZipCode =	'22968'	, strLocalityName =	'Greene County'	, intMasterId =	4601149
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51079'	, strLocalityZipCode =	'22973'	, strLocalityName =	'Greene County'	, intMasterId =	4601150
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51081'	, strLocalityZipCode =	'23828'	, strLocalityName =	'Greensville County'	, intMasterId =	4601151
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51081'	, strLocalityZipCode =	'23847'	, strLocalityName =	'Greensville County'	, intMasterId =	4601152
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51081'	, strLocalityZipCode =	'23856'	, strLocalityName =	'Greensville County'	, intMasterId =	4601153
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51081'	, strLocalityZipCode =	'23867'	, strLocalityName =	'Greensville County'	, intMasterId =	4601154
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51081'	, strLocalityZipCode =	'23879'	, strLocalityName =	'Greensville County'	, intMasterId =	4601155
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51081'	, strLocalityZipCode =	'23887'	, strLocalityName =	'Greensville County'	, intMasterId =	4601156
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51083'	, strLocalityZipCode =	'23962'	, strLocalityName =	'Halifax County'	, intMasterId =	4601157
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51083'	, strLocalityZipCode =	'24520'	, strLocalityName =	'Halifax County'	, intMasterId =	4601158
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51083'	, strLocalityZipCode =	'24529'	, strLocalityName =	'Halifax County'	, intMasterId =	4601159
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51083'	, strLocalityZipCode =	'24534'	, strLocalityName =	'Halifax County'	, intMasterId =	4601160
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51083'	, strLocalityZipCode =	'24535'	, strLocalityName =	'Halifax County'	, intMasterId =	4601161
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51083'	, strLocalityZipCode =	'24539'	, strLocalityName =	'Halifax County'	, intMasterId =	4601162
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51083'	, strLocalityZipCode =	'24558'	, strLocalityName =	'Halifax County'	, intMasterId =	4601163
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51083'	, strLocalityZipCode =	'24565'	, strLocalityName =	'Halifax County'	, intMasterId =	4601164
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51083'	, strLocalityZipCode =	'24569'	, strLocalityName =	'Halifax County'	, intMasterId =	4601165
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51083'	, strLocalityZipCode =	'24577'	, strLocalityName =	'Halifax County'	, intMasterId =	4601166
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51083'	, strLocalityZipCode =	'24589'	, strLocalityName =	'Halifax County'	, intMasterId =	4601167
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51083'	, strLocalityZipCode =	'24592'	, strLocalityName =	'Halifax County'	, intMasterId =	4601168
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51083'	, strLocalityZipCode =	'24594'	, strLocalityName =	'Halifax County'	, intMasterId =	4601169
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51083'	, strLocalityZipCode =	'24597'	, strLocalityName =	'Halifax County'	, intMasterId =	4601170
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51083'	, strLocalityZipCode =	'24598'	, strLocalityName =	'Halifax County'	, intMasterId =	4601171
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51650'	, strLocalityZipCode =	'23605'	, strLocalityName =	'Hampton, City of'	, intMasterId =	4601172
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51650'	, strLocalityZipCode =	'23630'	, strLocalityName =	'Hampton, City of'	, intMasterId =	4601173
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51650'	, strLocalityZipCode =	'23651'	, strLocalityName =	'Hampton, City of'	, intMasterId =	4601174
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51650'	, strLocalityZipCode =	'23661'	, strLocalityName =	'Hampton, City of'	, intMasterId =	4601175
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51650'	, strLocalityZipCode =	'23663'	, strLocalityName =	'Hampton, City of'	, intMasterId =	4601176
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51650'	, strLocalityZipCode =	'23664'	, strLocalityName =	'Hampton, City of'	, intMasterId =	4601177
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51650'	, strLocalityZipCode =	'23665'	, strLocalityName =	'Hampton, City of'	, intMasterId =	4601178
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51650'	, strLocalityZipCode =	'23666'	, strLocalityName =	'Hampton, City of'	, intMasterId =	4601179
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51650'	, strLocalityZipCode =	'23667'	, strLocalityName =	'Hampton, City of'	, intMasterId =	4601180
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51650'	, strLocalityZipCode =	'23668'	, strLocalityName =	'Hampton, City of'	, intMasterId =	4601181
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51650'	, strLocalityZipCode =	'23669'	, strLocalityName =	'Hampton, City of'	, intMasterId =	4601182
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51650'	, strLocalityZipCode =	'23681'	, strLocalityName =	'Hampton, City of'	, intMasterId =	4601183
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51085'	, strLocalityZipCode =	'22546'	, strLocalityName =	'Hanover County'	, intMasterId =	4601184
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51085'	, strLocalityZipCode =	'23005'	, strLocalityName =	'Hanover County'	, intMasterId =	4601185
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51085'	, strLocalityZipCode =	'23015'	, strLocalityName =	'Hanover County'	, intMasterId =	4601186
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51085'	, strLocalityZipCode =	'23024'	, strLocalityName =	'Hanover County'	, intMasterId =	4601187
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51085'	, strLocalityZipCode =	'23047'	, strLocalityName =	'Hanover County'	, intMasterId =	4601188
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51085'	, strLocalityZipCode =	'23059'	, strLocalityName =	'Hanover County'	, intMasterId =	4601189
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51085'	, strLocalityZipCode =	'23069'	, strLocalityName =	'Hanover County'	, intMasterId =	4601190
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51085'	, strLocalityZipCode =	'23102'	, strLocalityName =	'Hanover County'	, intMasterId =	4601191
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51085'	, strLocalityZipCode =	'23111'	, strLocalityName =	'Hanover County'	, intMasterId =	4601192
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51085'	, strLocalityZipCode =	'23116'	, strLocalityName =	'Hanover County'	, intMasterId =	4601193
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51085'	, strLocalityZipCode =	'23124'	, strLocalityName =	'Hanover County'	, intMasterId =	4601194
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51085'	, strLocalityZipCode =	'23146'	, strLocalityName =	'Hanover County'	, intMasterId =	4601195
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51085'	, strLocalityZipCode =	'23162'	, strLocalityName =	'Hanover County'	, intMasterId =	4601196
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51085'	, strLocalityZipCode =	'23192'	, strLocalityName =	'Hanover County'	, intMasterId =	4601197
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51660'	, strLocalityZipCode =	'22801'	, strLocalityName =	'Harrisonburg, City of'	, intMasterId =	4601198
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51660'	, strLocalityZipCode =	'22802'	, strLocalityName =	'Harrisonburg, City of'	, intMasterId =	4601199
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51660'	, strLocalityZipCode =	'22807'	, strLocalityName =	'Harrisonburg, City of'	, intMasterId =	4601200
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51087'	, strLocalityZipCode =	'23030'	, strLocalityName =	'Henrico County'	, intMasterId =	4601201
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51087'	, strLocalityZipCode =	'23058'	, strLocalityName =	'Henrico County'	, intMasterId =	4601202
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51087'	, strLocalityZipCode =	'23059'	, strLocalityName =	'Henrico County'	, intMasterId =	4601203
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51087'	, strLocalityZipCode =	'23060'	, strLocalityName =	'Henrico County'	, intMasterId =	4601204
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51087'	, strLocalityZipCode =	'23075'	, strLocalityName =	'Henrico County'	, intMasterId =	4601205
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51087'	, strLocalityZipCode =	'23150'	, strLocalityName =	'Henrico County'	, intMasterId =	4601206
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51087'	, strLocalityZipCode =	'23222'	, strLocalityName =	'Henrico County'	, intMasterId =	4601207
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51087'	, strLocalityZipCode =	'23223'	, strLocalityName =	'Henrico County'	, intMasterId =	4601208
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51087'	, strLocalityZipCode =	'23226'	, strLocalityName =	'Henrico County'	, intMasterId =	4601209
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51087'	, strLocalityZipCode =	'23227'	, strLocalityName =	'Henrico County'	, intMasterId =	4601210
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51087'	, strLocalityZipCode =	'23228'	, strLocalityName =	'Henrico County'	, intMasterId =	4601211
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51087'	, strLocalityZipCode =	'23229'	, strLocalityName =	'Henrico County'	, intMasterId =	4601212
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51087'	, strLocalityZipCode =	'23230'	, strLocalityName =	'Henrico County'	, intMasterId =	4601213
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51087'	, strLocalityZipCode =	'23231'	, strLocalityName =	'Henrico County'	, intMasterId =	4601214
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51087'	, strLocalityZipCode =	'23233'	, strLocalityName =	'Henrico County'	, intMasterId =	4601215
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51087'	, strLocalityZipCode =	'23238'	, strLocalityName =	'Henrico County'	, intMasterId =	4601216
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51087'	, strLocalityZipCode =	'23250'	, strLocalityName =	'Henrico County'	, intMasterId =	4601217
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51087'	, strLocalityZipCode =	'23255'	, strLocalityName =	'Henrico County'	, intMasterId =	4601218
							
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51087'	, strLocalityZipCode =	'23288'	, strLocalityName =	'Henrico County'	, intMasterId =	4601219
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51087'	, strLocalityZipCode =	'23294'	, strLocalityName =	'Henrico County'	, intMasterId =	4601220
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51089'	, strLocalityZipCode =	'24054'	, strLocalityName =	'Henry County'	, intMasterId =	4601221
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51089'	, strLocalityZipCode =	'24055'	, strLocalityName =	'Henry County'	, intMasterId =	4601222
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51089'	, strLocalityZipCode =	'24078'	, strLocalityName =	'Henry County'	, intMasterId =	4601223
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51089'	, strLocalityZipCode =	'24089'	, strLocalityName =	'Henry County'	, intMasterId =	4601224
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51089'	, strLocalityZipCode =	'24112'	, strLocalityName =	'Henry County'	, intMasterId =	4601225
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51089'	, strLocalityZipCode =	'24133'	, strLocalityName =	'Henry County'	, intMasterId =	4601226
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51089'	, strLocalityZipCode =	'24148'	, strLocalityName =	'Henry County'	, intMasterId =	4601227
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51089'	, strLocalityZipCode =	'24165'	, strLocalityName =	'Henry County'	, intMasterId =	4601228
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51089'	, strLocalityZipCode =	'24168'	, strLocalityName =	'Henry County'	, intMasterId =	4601229
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51089'	, strLocalityZipCode =	'24530'	, strLocalityName =	'Henry County'	, intMasterId =	4601230
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51091'	, strLocalityZipCode =	'24413'	, strLocalityName =	'Highland County'	, intMasterId =	4601231
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51091'	, strLocalityZipCode =	'24433'	, strLocalityName =	'Highland County'	, intMasterId =	4601232
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51091'	, strLocalityZipCode =	'24442'	, strLocalityName =	'Highland County'	, intMasterId =	4601233
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51091'	, strLocalityZipCode =	'24458'	, strLocalityName =	'Highland County'	, intMasterId =	4601234
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51091'	, strLocalityZipCode =	'24465'	, strLocalityName =	'Highland County'	, intMasterId =	4601235
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51091'	, strLocalityZipCode =	'24468'	, strLocalityName =	'Highland County'	, intMasterId =	4601236
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51670'	, strLocalityZipCode =	'23860'	, strLocalityName =	'Hopewell, City of'	, intMasterId =	4601237
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51093'	, strLocalityZipCode =	'23304'	, strLocalityName =	'Isle of Wight County'	, intMasterId =	4601238
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51093'	, strLocalityZipCode =	'23314'	, strLocalityName =	'Isle of Wight County'	, intMasterId =	4601239
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51093'	, strLocalityZipCode =	'23315'	, strLocalityName =	'Isle of Wight County'	, intMasterId =	4601240
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51093'	, strLocalityZipCode =	'23430'	, strLocalityName =	'Isle of Wight County'	, intMasterId =	4601241
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51093'	, strLocalityZipCode =	'23487'	, strLocalityName =	'Isle of Wight County'	, intMasterId =	4601242
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51093'	, strLocalityZipCode =	'23851'	, strLocalityName =	'Isle of Wight County'	, intMasterId =	4601243
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51093'	, strLocalityZipCode =	'23866'	, strLocalityName =	'Isle of Wight County'	, intMasterId =	4601244
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51093'	, strLocalityZipCode =	'23898'	, strLocalityName =	'Isle of Wight County'	, intMasterId =	4601245
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51095'	, strLocalityZipCode =	'23011'	, strLocalityName =	'James City County'	, intMasterId =	4601246
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51095'	, strLocalityZipCode =	'23081'	, strLocalityName =	'James City County'	, intMasterId =	4601247
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51095'	, strLocalityZipCode =	'23089'	, strLocalityName =	'James City County'	, intMasterId =	4601248
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51095'	, strLocalityZipCode =	'23168'	, strLocalityName =	'James City County'	, intMasterId =	4601249
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51095'	, strLocalityZipCode =	'23185'	, strLocalityName =	'James City County'	, intMasterId =	4601250
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51095'	, strLocalityZipCode =	'23188'	, strLocalityName =	'James City County'	, intMasterId =	4601251
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51097'	, strLocalityZipCode =	'22437'	, strLocalityName =	'King & Queen County'	, intMasterId =	4601252
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51097'	, strLocalityZipCode =	'22514'	, strLocalityName =	'King & Queen County'	, intMasterId =	4601253
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51097'	, strLocalityZipCode =	'22560'	, strLocalityName =	'King & Queen County'	, intMasterId =	4601254
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51097'	, strLocalityZipCode =	'23023'	, strLocalityName =	'King & Queen County'	, intMasterId =	4601255
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51097'	, strLocalityZipCode =	'23032'	, strLocalityName =	'King & Queen County'	, intMasterId =	4601256
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51097'	, strLocalityZipCode =	'23085'	, strLocalityName =	'King & Queen County'	, intMasterId =	4601257
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51097'	, strLocalityZipCode =	'23091'	, strLocalityName =	'King & Queen County'	, intMasterId =	4601258
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51097'	, strLocalityZipCode =	'23108'	, strLocalityName =	'King & Queen County'	, intMasterId =	4601259
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51097'	, strLocalityZipCode =	'23110'	, strLocalityName =	'King & Queen County'	, intMasterId =	4601260
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51097'	, strLocalityZipCode =	'23126'	, strLocalityName =	'King & Queen County'	, intMasterId =	4601261
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51097'	, strLocalityZipCode =	'23148'	, strLocalityName =	'King & Queen County'	, intMasterId =	4601262
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51097'	, strLocalityZipCode =	'23149'	, strLocalityName =	'King & Queen County'	, intMasterId =	4601263
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51097'	, strLocalityZipCode =	'23156'	, strLocalityName =	'King & Queen County'	, intMasterId =	4601264
							
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51097'	, strLocalityZipCode =	'23161'	, strLocalityName =	'King & Queen County'	, intMasterId =	4601265
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51097'	, strLocalityZipCode =	'23177'	, strLocalityName =	'King & Queen County'	, intMasterId =	4601266
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51099'	, strLocalityZipCode =	'22448'	, strLocalityName =	'King George County'	, intMasterId =	4601267
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51099'	, strLocalityZipCode =	'22451'	, strLocalityName =	'King George County'	, intMasterId =	4601268
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51099'	, strLocalityZipCode =	'22481'	, strLocalityName =	'King George County'	, intMasterId =	4601269
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51099'	, strLocalityZipCode =	'22485'	, strLocalityName =	'King George County'	, intMasterId =	4601270
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51099'	, strLocalityZipCode =	'22526'	, strLocalityName =	'King George County'	, intMasterId =	4601271
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51099'	, strLocalityZipCode =	'22544'	, strLocalityName =	'King George County'	, intMasterId =	4601272
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51099'	, strLocalityZipCode =	'22547'	, strLocalityName =	'King George County'	, intMasterId =	4601273
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51101'	, strLocalityZipCode =	'23009'	, strLocalityName =	'King William County'	, intMasterId =	4601274
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51101'	, strLocalityZipCode =	'23069'	, strLocalityName =	'King William County'	, intMasterId =	4601275
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51101'	, strLocalityZipCode =	'23086'	, strLocalityName =	'King William County'	, intMasterId =	4601276
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51101'	, strLocalityZipCode =	'23106'	, strLocalityName =	'King William County'	, intMasterId =	4601277
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51101'	, strLocalityZipCode =	'23177'	, strLocalityName =	'King William County'	, intMasterId =	4601278
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51101'	, strLocalityZipCode =	'23181'	, strLocalityName =	'King William County'	, intMasterId =	4601279
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51103'	, strLocalityZipCode =	'22473'	, strLocalityName =	'Lancaster County'	, intMasterId =	4601280
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51103'	, strLocalityZipCode =	'22480'	, strLocalityName =	'Lancaster County'	, intMasterId =	4601281
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51103'	, strLocalityZipCode =	'22482'	, strLocalityName =	'Lancaster County'	, intMasterId =	4601282
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51103'	, strLocalityZipCode =	'22503'	, strLocalityName =	'Lancaster County'	, intMasterId =	4601283
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51103'	, strLocalityZipCode =	'22507'	, strLocalityName =	'Lancaster County'	, intMasterId =	4601284
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51103'	, strLocalityZipCode =	'22513'	, strLocalityName =	'Lancaster County'	, intMasterId =	4601285
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51103'	, strLocalityZipCode =	'22517'	, strLocalityName =	'Lancaster County'	, intMasterId =	4601286
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51103'	, strLocalityZipCode =	'22523'	, strLocalityName =	'Lancaster County'	, intMasterId =	4601287
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51103'	, strLocalityZipCode =	'22528'	, strLocalityName =	'Lancaster County'	, intMasterId =	4601288
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51103'	, strLocalityZipCode =	'22576'	, strLocalityName =	'Lancaster County'	, intMasterId =	4601289
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51103'	, strLocalityZipCode =	'22578'	, strLocalityName =	'Lancaster County'	, intMasterId =	4601290
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51105'	, strLocalityZipCode =	'24218'	, strLocalityName =	'Lee County'	, intMasterId =	4601291
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51105'	, strLocalityZipCode =	'24219'	, strLocalityName =	'Lee County'	, intMasterId =	4601292
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51105'	, strLocalityZipCode =	'24221'	, strLocalityName =	'Lee County'	, intMasterId =	4601293
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51105'	, strLocalityZipCode =	'24243'	, strLocalityName =	'Lee County'	, intMasterId =	4601294
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51105'	, strLocalityZipCode =	'24244'	, strLocalityName =	'Lee County'	, intMasterId =	4601295
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51105'	, strLocalityZipCode =	'24248'	, strLocalityName =	'Lee County'	, intMasterId =	4601296
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51105'	, strLocalityZipCode =	'24263'	, strLocalityName =	'Lee County'	, intMasterId =	4601297
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51105'	, strLocalityZipCode =	'24265'	, strLocalityName =	'Lee County'	, intMasterId =	4601298
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51105'	, strLocalityZipCode =	'24277'	, strLocalityName =	'Lee County'	, intMasterId =	4601299
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51105'	, strLocalityZipCode =	'24281'	, strLocalityName =	'Lee County'	, intMasterId =	4601300
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51105'	, strLocalityZipCode =	'24282'	, strLocalityName =	'Lee County'	, intMasterId =	4601301
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51678'	, strLocalityZipCode =	'24450'	, strLocalityName =	'Lexington, City of'	, intMasterId =	4601302
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51107'	, strLocalityZipCode =	'20105'	, strLocalityName =	'Loudoun County'	, intMasterId =	4601303
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51107'	, strLocalityZipCode =	'20117'	, strLocalityName =	'Loudoun County'	, intMasterId =	4601304
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51107'	, strLocalityZipCode =	'20120'	, strLocalityName =	'Loudoun County'	, intMasterId =	4601305
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51107'	, strLocalityZipCode =	'20129'	, strLocalityName =	'Loudoun County'	, intMasterId =	4601306
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51107'	, strLocalityZipCode =	'20132'	, strLocalityName =	'Loudoun County'	, intMasterId =	4601307
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51107'	, strLocalityZipCode =	'20135'	, strLocalityName =	'Loudoun County'	, intMasterId =	4601308
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51107'	, strLocalityZipCode =	'20141'	, strLocalityName =	'Loudoun County'	, intMasterId =	4601309
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51107'	, strLocalityZipCode =	'20147'	, strLocalityName =	'Loudoun County'	, intMasterId =	4601310
							
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51107'	, strLocalityZipCode =	'20148'	, strLocalityName =	'Loudoun County'	, intMasterId =	4601311
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51107'	, strLocalityZipCode =	'20152'	, strLocalityName =	'Loudoun County'	, intMasterId =	4601312
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51107'	, strLocalityZipCode =	'20158'	, strLocalityName =	'Loudoun County'	, intMasterId =	4601313
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51107'	, strLocalityZipCode =	'20164'	, strLocalityName =	'Loudoun County'	, intMasterId =	4601314
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51107'	, strLocalityZipCode =	'20165'	, strLocalityName =	'Loudoun County'	, intMasterId =	4601315
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51107'	, strLocalityZipCode =	'20166'	, strLocalityName =	'Loudoun County'	, intMasterId =	4601316
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51107'	, strLocalityZipCode =	'20175'	, strLocalityName =	'Loudoun County'	, intMasterId =	4601317
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51107'	, strLocalityZipCode =	'20176'	, strLocalityName =	'Loudoun County'	, intMasterId =	4601318
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51107'	, strLocalityZipCode =	'20180'	, strLocalityName =	'Loudoun County'	, intMasterId =	4601319
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51107'	, strLocalityZipCode =	'20184'	, strLocalityName =	'Loudoun County'	, intMasterId =	4601320
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51107'	, strLocalityZipCode =	'20197'	, strLocalityName =	'Loudoun County'	, intMasterId =	4601321
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51107'	, strLocalityZipCode =	'22066'	, strLocalityName =	'Loudoun County'	, intMasterId =	4601322
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51109'	, strLocalityZipCode =	'22942'	, strLocalityName =	'Louisa County'	, intMasterId =	4601323
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51109'	, strLocalityZipCode =	'22947'	, strLocalityName =	'Louisa County'	, intMasterId =	4601324
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51109'	, strLocalityZipCode =	'22974'	, strLocalityName =	'Louisa County'	, intMasterId =	4601325
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51109'	, strLocalityZipCode =	'23015'	, strLocalityName =	'Louisa County'	, intMasterId =	4601326
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51109'	, strLocalityZipCode =	'23024'	, strLocalityName =	'Louisa County'	, intMasterId =	4601327
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51109'	, strLocalityZipCode =	'23065'	, strLocalityName =	'Louisa County'	, intMasterId =	4601328
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51109'	, strLocalityZipCode =	'23084'	, strLocalityName =	'Louisa County'	, intMasterId =	4601329
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51109'	, strLocalityZipCode =	'23093'	, strLocalityName =	'Louisa County'	, intMasterId =	4601330
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51109'	, strLocalityZipCode =	'23102'	, strLocalityName =	'Louisa County'	, intMasterId =	4601331
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51109'	, strLocalityZipCode =	'23117'	, strLocalityName =	'Louisa County'	, intMasterId =	4601332
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51109'	, strLocalityZipCode =	'23170'	, strLocalityName =	'Louisa County'	, intMasterId =	4601333
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51109'	, strLocalityZipCode =	'23192'	, strLocalityName =	'Louisa County'	, intMasterId =	4601334
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51111'	, strLocalityZipCode =	'23824'	, strLocalityName =	'Lunenburg County'	, intMasterId =	4601335
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51111'	, strLocalityZipCode =	'23920'	, strLocalityName =	'Lunenburg County'	, intMasterId =	4601336
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51111'	, strLocalityZipCode =	'23924'	, strLocalityName =	'Lunenburg County'	, intMasterId =	4601337
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51111'	, strLocalityZipCode =	'23937'	, strLocalityName =	'Lunenburg County'	, intMasterId =	4601338
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51111'	, strLocalityZipCode =	'23938'	, strLocalityName =	'Lunenburg County'	, intMasterId =	4601339
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51111'	, strLocalityZipCode =	'23941'	, strLocalityName =	'Lunenburg County'	, intMasterId =	4601340
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51111'	, strLocalityZipCode =	'23942'	, strLocalityName =	'Lunenburg County'	, intMasterId =	4601341
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51111'	, strLocalityZipCode =	'23944'	, strLocalityName =	'Lunenburg County'	, intMasterId =	4601342
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51111'	, strLocalityZipCode =	'23947'	, strLocalityName =	'Lunenburg County'	, intMasterId =	4601343
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51111'	, strLocalityZipCode =	'23952'	, strLocalityName =	'Lunenburg County'	, intMasterId =	4601344
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51111'	, strLocalityZipCode =	'23954'	, strLocalityName =	'Lunenburg County'	, intMasterId =	4601345
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51111'	, strLocalityZipCode =	'23970'	, strLocalityName =	'Lunenburg County'	, intMasterId =	4601346
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51111'	, strLocalityZipCode =	'23974'	, strLocalityName =	'Lunenburg County'	, intMasterId =	4601347
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51680'	, strLocalityZipCode =	'24501'	, strLocalityName =	'Lynchburg, City of'	, intMasterId =	4601348
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51680'	, strLocalityZipCode =	'24502'	, strLocalityName =	'Lynchburg, City of'	, intMasterId =	4601349
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51680'	, strLocalityZipCode =	'24503'	, strLocalityName =	'Lynchburg, City of'	, intMasterId =	4601350
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51680'	, strLocalityZipCode =	'24504'	, strLocalityName =	'Lynchburg, City of'	, intMasterId =	4601351
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51680'	, strLocalityZipCode =	'24505'	, strLocalityName =	'Lynchburg, City of'	, intMasterId =	4601352
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51680'	, strLocalityZipCode =	'24506'	, strLocalityName =	'Lynchburg, City of'	, intMasterId =	4601353
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51680'	, strLocalityZipCode =	'24513'	, strLocalityName =	'Lynchburg, City of'	, intMasterId =	4601354
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51680'	, strLocalityZipCode =	'24514'	, strLocalityName =	'Lynchburg, City of'	, intMasterId =	4601355
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51680'	, strLocalityZipCode =	'24515'	, strLocalityName =	'Lynchburg, City of'	, intMasterId =	4601356
							
							
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51680'	, strLocalityZipCode =	'24551'	, strLocalityName =	'Lynchburg, City of'	, intMasterId =	4601357
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22701'	, strLocalityName =	'Madison County'	, intMasterId =	4601358
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22709'	, strLocalityName =	'Madison County'	, intMasterId =	4601359
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22711'	, strLocalityName =	'Madison County'	, intMasterId =	4601360
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22715'	, strLocalityName =	'Madison County'	, intMasterId =	4601361
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22719'	, strLocalityName =	'Madison County'	, intMasterId =	4601362
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22722'	, strLocalityName =	'Madison County'	, intMasterId =	4601363
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22723'	, strLocalityName =	'Madison County'	, intMasterId =	4601364
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22725'	, strLocalityName =	'Madison County'	, intMasterId =	4601365
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22727'	, strLocalityName =	'Madison County'	, intMasterId =	4601366
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22730'	, strLocalityName =	'Madison County'	, intMasterId =	4601367
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22731'	, strLocalityName =	'Madison County'	, intMasterId =	4601368
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22732'	, strLocalityName =	'Madison County'	, intMasterId =	4601369
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22733'	, strLocalityName =	'Madison County'	, intMasterId =	4601370
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22735'	, strLocalityName =	'Madison County'	, intMasterId =	4601371
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22738'	, strLocalityName =	'Madison County'	, intMasterId =	4601372
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22740'	, strLocalityName =	'Madison County'	, intMasterId =	4601373
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22743'	, strLocalityName =	'Madison County'	, intMasterId =	4601374
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22748'	, strLocalityName =	'Madison County'	, intMasterId =	4601375
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22948'	, strLocalityName =	'Madison County'	, intMasterId =	4601376
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22960'	, strLocalityName =	'Madison County'	, intMasterId =	4601377
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22972'	, strLocalityName =	'Madison County'	, intMasterId =	4601378
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22973'	, strLocalityName =	'Madison County'	, intMasterId =	4601379
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51113'	, strLocalityZipCode =	'22989'	, strLocalityName =	'Madison County'	, intMasterId =	4601380
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51685'	, strLocalityZipCode =	'20110'	, strLocalityName =	'Manassas Park, City of'	, intMasterId =	4601381
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51685'	, strLocalityZipCode =	'20111'	, strLocalityName =	'Manassas Park, City of'	, intMasterId =	4601382
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51683'	, strLocalityZipCode =	'20110'	, strLocalityName =	'Manassas, City of'	, intMasterId =	4601383
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51690'	, strLocalityZipCode =	'24112'	, strLocalityName =	'Martinsville, City of'	, intMasterId =	4601384
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51690'	, strLocalityZipCode =	'24113'	, strLocalityName =	'Martinsville, City of'	, intMasterId =	4601385
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51690'	, strLocalityZipCode =	'24114'	, strLocalityName =	'Martinsville, City of'	, intMasterId =	4601386
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51690'	, strLocalityZipCode =	'24115'	, strLocalityName =	'Martinsville, City of'	, intMasterId =	4601387
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51115'	, strLocalityZipCode =	'23021'	, strLocalityName =	'Mathews County'	, intMasterId =	4601388
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51115'	, strLocalityZipCode =	'23025'	, strLocalityName =	'Mathews County'	, intMasterId =	4601389
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51115'	, strLocalityZipCode =	'23035'	, strLocalityName =	'Mathews County'	, intMasterId =	4601390
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51115'	, strLocalityZipCode =	'23045'	, strLocalityName =	'Mathews County'	, intMasterId =	4601391
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51115'	, strLocalityZipCode =	'23050'	, strLocalityName =	'Mathews County'	, intMasterId =	4601392
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51115'	, strLocalityZipCode =	'23056'	, strLocalityName =	'Mathews County'	, intMasterId =	4601393
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51115'	, strLocalityZipCode =	'23064'	, strLocalityName =	'Mathews County'	, intMasterId =	4601394
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51115'	, strLocalityZipCode =	'23066'	, strLocalityName =	'Mathews County'	, intMasterId =	4601395
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51115'	, strLocalityZipCode =	'23068'	, strLocalityName =	'Mathews County'	, intMasterId =	4601396
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51115'	, strLocalityZipCode =	'23076'	, strLocalityName =	'Mathews County'	, intMasterId =	4601397
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51115'	, strLocalityZipCode =	'23109'	, strLocalityName =	'Mathews County'	, intMasterId =	4601398
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51115'	, strLocalityZipCode =	'23119'	, strLocalityName =	'Mathews County'	, intMasterId =	4601399
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51115'	, strLocalityZipCode =	'23125'	, strLocalityName =	'Mathews County'	, intMasterId =	4601400
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51115'	, strLocalityZipCode =	'23128'	, strLocalityName =	'Mathews County'	, intMasterId =	4601401
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51115'	, strLocalityZipCode =	'23130'	, strLocalityName =	'Mathews County'	, intMasterId =	4601402
							
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51115'	, strLocalityZipCode =	'23138'	, strLocalityName =	'Mathews County'	, intMasterId =	4601403
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51115'	, strLocalityZipCode =	'23163'	, strLocalityName =	'Mathews County'	, intMasterId =	4601404
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51117'	, strLocalityZipCode =	'23915'	, strLocalityName =	'Mecklenburg County'	, intMasterId =	4601405
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51117'	, strLocalityZipCode =	'23917'	, strLocalityName =	'Mecklenburg County'	, intMasterId =	4601406
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51117'	, strLocalityZipCode =	'23919'	, strLocalityName =	'Mecklenburg County'	, intMasterId =	4601407
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51117'	, strLocalityZipCode =	'23920'	, strLocalityName =	'Mecklenburg County'	, intMasterId =	4601408
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51117'	, strLocalityZipCode =	'23924'	, strLocalityName =	'Mecklenburg County'	, intMasterId =	4601409
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51117'	, strLocalityZipCode =	'23927'	, strLocalityName =	'Mecklenburg County'	, intMasterId =	4601410
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51117'	, strLocalityZipCode =	'23950'	, strLocalityName =	'Mecklenburg County'	, intMasterId =	4601411
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51117'	, strLocalityZipCode =	'23964'	, strLocalityName =	'Mecklenburg County'	, intMasterId =	4601412
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51117'	, strLocalityZipCode =	'23968'	, strLocalityName =	'Mecklenburg County'	, intMasterId =	4601413
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51117'	, strLocalityZipCode =	'23970'	, strLocalityName =	'Mecklenburg County'	, intMasterId =	4601414
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51117'	, strLocalityZipCode =	'24529'	, strLocalityName =	'Mecklenburg County'	, intMasterId =	4601415
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51117'	, strLocalityZipCode =	'24580'	, strLocalityName =	'Mecklenburg County'	, intMasterId =	4601416
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51117'	, strLocalityZipCode =	'24598'	, strLocalityName =	'Mecklenburg County'	, intMasterId =	4601417
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51117'	, strLocalityZipCode =	'27507'	, strLocalityName =	'Mecklenburg County'	, intMasterId =	4601418
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51117'	, strLocalityZipCode =	'27537'	, strLocalityName =	'Mecklenburg County'	, intMasterId =	4601419
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51117'	, strLocalityZipCode =	'27551'	, strLocalityName =	'Mecklenburg County'	, intMasterId =	4601420
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51117'	, strLocalityZipCode =	'27589'	, strLocalityName =	'Mecklenburg County'	, intMasterId =	4601421
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51119'	, strLocalityZipCode =	'22504'	, strLocalityName =	'Middlesex County'	, intMasterId =	4601422
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51119'	, strLocalityZipCode =	'23031'	, strLocalityName =	'Middlesex County'	, intMasterId =	4601423
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51119'	, strLocalityZipCode =	'23032'	, strLocalityName =	'Middlesex County'	, intMasterId =	4601424
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51119'	, strLocalityZipCode =	'23043'	, strLocalityName =	'Middlesex County'	, intMasterId =	4601425
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51119'	, strLocalityZipCode =	'23070'	, strLocalityName =	'Middlesex County'	, intMasterId =	4601426
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51119'	, strLocalityZipCode =	'23071'	, strLocalityName =	'Middlesex County'	, intMasterId =	4601427
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51119'	, strLocalityZipCode =	'23079'	, strLocalityName =	'Middlesex County'	, intMasterId =	4601428
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51119'	, strLocalityZipCode =	'23092'	, strLocalityName =	'Middlesex County'	, intMasterId =	4601429
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51119'	, strLocalityZipCode =	'23149'	, strLocalityName =	'Middlesex County'	, intMasterId =	4601430
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51119'	, strLocalityZipCode =	'23169'	, strLocalityName =	'Middlesex County'	, intMasterId =	4601431
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51119'	, strLocalityZipCode =	'23175'	, strLocalityName =	'Middlesex County'	, intMasterId =	4601432
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51119'	, strLocalityZipCode =	'23176'	, strLocalityName =	'Middlesex County'	, intMasterId =	4601433
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51119'	, strLocalityZipCode =	'23180'	, strLocalityName =	'Middlesex County'	, intMasterId =	4601434
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24059'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601435
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24060'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601436
--UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24060'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601437
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24061'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601438
--UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24061'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601439
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24070'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601440
--UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24070'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601441
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24073'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601442
--UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24073'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601443
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24087'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601444
--UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24087'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601445
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24128'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601446
--UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24128'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601447
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24138'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601448
--UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24138'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601449
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24141'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601450
--UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24141'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601451
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24149'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601452
--UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24149'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601453
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24162'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601454
--UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24162'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601455
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24347'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601456
--UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51121'	, strLocalityZipCode =	'24347'	, strLocalityName =	'Montgomery County'	, intMasterId =	4601457
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51125'	, strLocalityZipCode =	'22920'	, strLocalityName =	'Nelson County'	, intMasterId =	4601458
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51125'	, strLocalityZipCode =	'22922'	, strLocalityName =	'Nelson County'	, intMasterId =	4601459
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51125'	, strLocalityZipCode =	'22938'	, strLocalityName =	'Nelson County'	, intMasterId =	4601460
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51125'	, strLocalityZipCode =	'22949'	, strLocalityName =	'Nelson County'	, intMasterId =	4601461
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51125'	, strLocalityZipCode =	'22952'	, strLocalityName =	'Nelson County'	, intMasterId =	4601462
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51125'	, strLocalityZipCode =	'22958'	, strLocalityName =	'Nelson County'	, intMasterId =	4601463
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51125'	, strLocalityZipCode =	'22964'	, strLocalityName =	'Nelson County'	, intMasterId =	4601464
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51125'	, strLocalityZipCode =	'22967'	, strLocalityName =	'Nelson County'	, intMasterId =	4601465
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51125'	, strLocalityZipCode =	'22969'	, strLocalityName =	'Nelson County'	, intMasterId =	4601466
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51125'	, strLocalityZipCode =	'22971'	, strLocalityName =	'Nelson County'	, intMasterId =	4601467
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51125'	, strLocalityZipCode =	'22976'	, strLocalityName =	'Nelson County'	, intMasterId =	4601468
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51125'	, strLocalityZipCode =	'24464'	, strLocalityName =	'Nelson County'	, intMasterId =	4601469
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51125'	, strLocalityZipCode =	'24483'	, strLocalityName =	'Nelson County'	, intMasterId =	4601470
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51125'	, strLocalityZipCode =	'24521'	, strLocalityName =	'Nelson County'	, intMasterId =	4601471
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51125'	, strLocalityZipCode =	'24553'	, strLocalityName =	'Nelson County'	, intMasterId =	4601472
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51125'	, strLocalityZipCode =	'24562'	, strLocalityName =	'Nelson County'	, intMasterId =	4601473
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51125'	, strLocalityZipCode =	'24581'	, strLocalityName =	'Nelson County'	, intMasterId =	4601474
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51125'	, strLocalityZipCode =	'24599'	, strLocalityName =	'Nelson County'	, intMasterId =	4601475
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51127'	, strLocalityZipCode =	'23011'	, strLocalityName =	'New Kent County'	, intMasterId =	4601476
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51127'	, strLocalityZipCode =	'23089'	, strLocalityName =	'New Kent County'	, intMasterId =	4601477
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51127'	, strLocalityZipCode =	'23111'	, strLocalityName =	'New Kent County'	, intMasterId =	4601478
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51127'	, strLocalityZipCode =	'23124'	, strLocalityName =	'New Kent County'	, intMasterId =	4601479
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51127'	, strLocalityZipCode =	'23140'	, strLocalityName =	'New Kent County'	, intMasterId =	4601480
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51127'	, strLocalityZipCode =	'23141'	, strLocalityName =	'New Kent County'	, intMasterId =	4601481
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51127'	, strLocalityZipCode =	'23181'	, strLocalityName =	'New Kent County'	, intMasterId =	4601482
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51700'	, strLocalityZipCode =	'23601'	, strLocalityName =	'Newport News, City of'	, intMasterId =	4601483
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51700'	, strLocalityZipCode =	'23602'	, strLocalityName =	'Newport News, City of'	, intMasterId =	4601484
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51700'	, strLocalityZipCode =	'23603'	, strLocalityName =	'Newport News, City of'	, intMasterId =	4601485
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51700'	, strLocalityZipCode =	'23604'	, strLocalityName =	'Newport News, City of'	, intMasterId =	4601486
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51700'	, strLocalityZipCode =	'23605'	, strLocalityName =	'Newport News, City of'	, intMasterId =	4601487
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51700'	, strLocalityZipCode =	'23606'	, strLocalityName =	'Newport News, City of'	, intMasterId =	4601488
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51700'	, strLocalityZipCode =	'23607'	, strLocalityName =	'Newport News, City of'	, intMasterId =	4601489
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51700'	, strLocalityZipCode =	'23608'	, strLocalityName =	'Newport News, City of'	, intMasterId =	4601490
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51700'	, strLocalityZipCode =	'23628'	, strLocalityName =	'Newport News, City of'	, intMasterId =	4601491
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51710'	, strLocalityZipCode =	'23455'	, strLocalityName =	'Norfolk, City of'	, intMasterId =	4601492
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51710'	, strLocalityZipCode =	'23459'	, strLocalityName =	'Norfolk, City of'	, intMasterId =	4601493
							
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51710'	, strLocalityZipCode =	'23502'	, strLocalityName =	'Norfolk, City of'	, intMasterId =	4601494
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51710'	, strLocalityZipCode =	'23503'	, strLocalityName =	'Norfolk, City of'	, intMasterId =	4601495
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51710'	, strLocalityZipCode =	'23504'	, strLocalityName =	'Norfolk, City of'	, intMasterId =	4601496
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51710'	, strLocalityZipCode =	'23505'	, strLocalityName =	'Norfolk, City of'	, intMasterId =	4601497
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51710'	, strLocalityZipCode =	'23507'	, strLocalityName =	'Norfolk, City of'	, intMasterId =	4601498
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51710'	, strLocalityZipCode =	'23508'	, strLocalityName =	'Norfolk, City of'	, intMasterId =	4601499
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51710'	, strLocalityZipCode =	'23509'	, strLocalityName =	'Norfolk, City of'	, intMasterId =	4601500
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51710'	, strLocalityZipCode =	'23510'	, strLocalityName =	'Norfolk, City of'	, intMasterId =	4601501
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51710'	, strLocalityZipCode =	'23511'	, strLocalityName =	'Norfolk, City of'	, intMasterId =	4601502
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51710'	, strLocalityZipCode =	'23513'	, strLocalityName =	'Norfolk, City of'	, intMasterId =	4601503
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51710'	, strLocalityZipCode =	'23515'	, strLocalityName =	'Norfolk, City of'	, intMasterId =	4601504
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51710'	, strLocalityZipCode =	'23517'	, strLocalityName =	'Norfolk, City of'	, intMasterId =	4601505
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51710'	, strLocalityZipCode =	'23518'	, strLocalityName =	'Norfolk, City of'	, intMasterId =	4601506
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51710'	, strLocalityZipCode =	'23519'	, strLocalityName =	'Norfolk, City of'	, intMasterId =	4601507
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51710'	, strLocalityZipCode =	'23523'	, strLocalityName =	'Norfolk, City of'	, intMasterId =	4601508
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51710'	, strLocalityZipCode =	'23529'	, strLocalityName =	'Norfolk, City of'	, intMasterId =	4601509
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51710'	, strLocalityZipCode =	'23551'	, strLocalityName =	'Norfolk, City of'	, intMasterId =	4601510
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51131'	, strLocalityZipCode =	'23307'	, strLocalityName =	'Northampton County'	, intMasterId =	4601511
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51131'	, strLocalityZipCode =	'23310'	, strLocalityName =	'Northampton County'	, intMasterId =	4601512
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51131'	, strLocalityZipCode =	'23313'	, strLocalityName =	'Northampton County'	, intMasterId =	4601513
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51131'	, strLocalityZipCode =	'23316'	, strLocalityName =	'Northampton County'	, intMasterId =	4601514
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51131'	, strLocalityZipCode =	'23347'	, strLocalityName =	'Northampton County'	, intMasterId =	4601515
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51131'	, strLocalityZipCode =	'23350'	, strLocalityName =	'Northampton County'	, intMasterId =	4601516
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51131'	, strLocalityZipCode =	'23354'	, strLocalityName =	'Northampton County'	, intMasterId =	4601517
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51131'	, strLocalityZipCode =	'23398'	, strLocalityName =	'Northampton County'	, intMasterId =	4601518
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51131'	, strLocalityZipCode =	'23405'	, strLocalityName =	'Northampton County'	, intMasterId =	4601519
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51131'	, strLocalityZipCode =	'23408'	, strLocalityName =	'Northampton County'	, intMasterId =	4601520
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51131'	, strLocalityZipCode =	'23413'	, strLocalityName =	'Northampton County'	, intMasterId =	4601521
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51131'	, strLocalityZipCode =	'23419'	, strLocalityName =	'Northampton County'	, intMasterId =	4601522
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51131'	, strLocalityZipCode =	'23429'	, strLocalityName =	'Northampton County'	, intMasterId =	4601523
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51131'	, strLocalityZipCode =	'23443'	, strLocalityName =	'Northampton County'	, intMasterId =	4601524
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51131'	, strLocalityZipCode =	'23482'	, strLocalityName =	'Northampton County'	, intMasterId =	4601525
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51131'	, strLocalityZipCode =	'23486'	, strLocalityName =	'Northampton County'	, intMasterId =	4601526
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51133'	, strLocalityZipCode =	'22432'	, strLocalityName =	'Northumberland County'	, intMasterId =	4601527
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51133'	, strLocalityZipCode =	'22435'	, strLocalityName =	'Northumberland County'	, intMasterId =	4601528
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51133'	, strLocalityZipCode =	'22456'	, strLocalityName =	'Northumberland County'	, intMasterId =	4601529
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51133'	, strLocalityZipCode =	'22460'	, strLocalityName =	'Northumberland County'	, intMasterId =	4601530
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51133'	, strLocalityZipCode =	'22473'	, strLocalityName =	'Northumberland County'	, intMasterId =	4601531
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51133'	, strLocalityZipCode =	'22482'	, strLocalityName =	'Northumberland County'	, intMasterId =	4601532
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51133'	, strLocalityZipCode =	'22488'	, strLocalityName =	'Northumberland County'	, intMasterId =	4601533
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51133'	, strLocalityZipCode =	'22503'	, strLocalityName =	'Northumberland County'	, intMasterId =	4601534
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51133'	, strLocalityZipCode =	'22511'	, strLocalityName =	'Northumberland County'	, intMasterId =	4601535
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51133'	, strLocalityZipCode =	'22530'	, strLocalityName =	'Northumberland County'	, intMasterId =	4601536
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51133'	, strLocalityZipCode =	'22539'	, strLocalityName =	'Northumberland County'	, intMasterId =	4601537
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51133'	, strLocalityZipCode =	'22579'	, strLocalityName =	'Northumberland County'	, intMasterId =	4601538
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51720'	, strLocalityZipCode =	'24273'	, strLocalityName =	'Norton, City of'	, intMasterId =	4601539
							
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51135'	, strLocalityZipCode =	'23002'	, strLocalityName =	'Nottoway County'	, intMasterId =	4601540
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51135'	, strLocalityZipCode =	'23083'	, strLocalityName =	'Nottoway County'	, intMasterId =	4601541
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51135'	, strLocalityZipCode =	'23824'	, strLocalityName =	'Nottoway County'	, intMasterId =	4601542
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51135'	, strLocalityZipCode =	'23894'	, strLocalityName =	'Nottoway County'	, intMasterId =	4601543
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51135'	, strLocalityZipCode =	'23922'	, strLocalityName =	'Nottoway County'	, intMasterId =	4601544
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51135'	, strLocalityZipCode =	'23930'	, strLocalityName =	'Nottoway County'	, intMasterId =	4601545
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51135'	, strLocalityZipCode =	'23955'	, strLocalityName =	'Nottoway County'	, intMasterId =	4601546
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51135'	, strLocalityZipCode =	'23966'	, strLocalityName =	'Nottoway County'	, intMasterId =	4601547
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51137'	, strLocalityZipCode =	'22433'	, strLocalityName =	'Orange County'	, intMasterId =	4601548
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51137'	, strLocalityZipCode =	'22508'	, strLocalityName =	'Orange County'	, intMasterId =	4601549
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51137'	, strLocalityZipCode =	'22542'	, strLocalityName =	'Orange County'	, intMasterId =	4601550
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51136'	, strLocalityZipCode =	'22551'	, strLocalityName =	'Orange County'	, intMasterId =	4601551
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51137'	, strLocalityZipCode =	'22567'	, strLocalityName =	'Orange County'	, intMasterId =	4601552
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51137'	, strLocalityZipCode =	'22701'	, strLocalityName =	'Orange County'	, intMasterId =	4601553
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51137'	, strLocalityZipCode =	'22733'	, strLocalityName =	'Orange County'	, intMasterId =	4601554
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51137'	, strLocalityZipCode =	'22923'	, strLocalityName =	'Orange County'	, intMasterId =	4601555
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51137'	, strLocalityZipCode =	'22942'	, strLocalityName =	'Orange County'	, intMasterId =	4601556
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51137'	, strLocalityZipCode =	'22957'	, strLocalityName =	'Orange County'	, intMasterId =	4601557
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51137'	, strLocalityZipCode =	'22960'	, strLocalityName =	'Orange County'	, intMasterId =	4601558
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51137'	, strLocalityZipCode =	'22968'	, strLocalityName =	'Orange County'	, intMasterId =	4601559
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51137'	, strLocalityZipCode =	'22972'	, strLocalityName =	'Orange County'	, intMasterId =	4601560
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51139'	, strLocalityZipCode =	'22610'	, strLocalityName =	'Page County'	, intMasterId =	4601561
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51139'	, strLocalityZipCode =	'22650'	, strLocalityName =	'Page County'	, intMasterId =	4601562
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51139'	, strLocalityZipCode =	'22815'	, strLocalityName =	'Page County'	, intMasterId =	4601563
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51139'	, strLocalityZipCode =	'22827'	, strLocalityName =	'Page County'	, intMasterId =	4601564
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51139'	, strLocalityZipCode =	'22835'	, strLocalityName =	'Page County'	, intMasterId =	4601565
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51139'	, strLocalityZipCode =	'22849'	, strLocalityName =	'Page County'	, intMasterId =	4601566
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51139'	, strLocalityZipCode =	'22851'	, strLocalityName =	'Page County'	, intMasterId =	4601567
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51141'	, strLocalityZipCode =	'24053'	, strLocalityName =	'Patrick County'	, intMasterId =	4601568
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51141'	, strLocalityZipCode =	'24055'	, strLocalityName =	'Patrick County'	, intMasterId =	4601569
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51141'	, strLocalityZipCode =	'24076'	, strLocalityName =	'Patrick County'	, intMasterId =	4601570
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51141'	, strLocalityZipCode =	'24082'	, strLocalityName =	'Patrick County'	, intMasterId =	4601571
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51141'	, strLocalityZipCode =	'24088'	, strLocalityName =	'Patrick County'	, intMasterId =	4601572
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51141'	, strLocalityZipCode =	'24120'	, strLocalityName =	'Patrick County'	, intMasterId =	4601573
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51141'	, strLocalityZipCode =	'24133'	, strLocalityName =	'Patrick County'	, intMasterId =	4601574
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51141'	, strLocalityZipCode =	'24165'	, strLocalityName =	'Patrick County'	, intMasterId =	4601575
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51141'	, strLocalityZipCode =	'24171'	, strLocalityName =	'Patrick County'	, intMasterId =	4601576
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51141'	, strLocalityZipCode =	'24177'	, strLocalityName =	'Patrick County'	, intMasterId =	4601577
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51141'	, strLocalityZipCode =	'24185'	, strLocalityName =	'Patrick County'	, intMasterId =	4601578
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51141'	, strLocalityZipCode =	'24317'	, strLocalityName =	'Patrick County'	, intMasterId =	4601579
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51141'	, strLocalityZipCode =	'24343'	, strLocalityName =	'Patrick County'	, intMasterId =	4601580
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51730'	, strLocalityZipCode =	'23803'	, strLocalityName =	'Petersburg, City of'	, intMasterId =	4601581
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51730'	, strLocalityZipCode =	'23804'	, strLocalityName =	'Petersburg, City of'	, intMasterId =	4601582
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51730'	, strLocalityZipCode =	'23805'	, strLocalityName =	'Petersburg, City of'	, intMasterId =	4601583
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51730'	, strLocalityZipCode =	'23806'	, strLocalityName =	'Petersburg, City of'	, intMasterId =	4601584
							
							
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51143'	, strLocalityZipCode =	'24054'	, strLocalityName =	'Pittsylvania County'	, intMasterId =	4601585
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51143'	, strLocalityZipCode =	'24069'	, strLocalityName =	'Pittsylvania County'	, intMasterId =	4601586
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51143'	, strLocalityZipCode =	'24137'	, strLocalityName =	'Pittsylvania County'	, intMasterId =	4601587
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51143'	, strLocalityZipCode =	'24139'	, strLocalityName =	'Pittsylvania County'	, intMasterId =	4601588
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51143'	, strLocalityZipCode =	'24161'	, strLocalityName =	'Pittsylvania County'	, intMasterId =	4601589
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51143'	, strLocalityZipCode =	'24527'	, strLocalityName =	'Pittsylvania County'	, intMasterId =	4601590
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51143'	, strLocalityZipCode =	'24530'	, strLocalityName =	'Pittsylvania County'	, intMasterId =	4601591
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51143'	, strLocalityZipCode =	'24531'	, strLocalityName =	'Pittsylvania County'	, intMasterId =	4601592
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51143'	, strLocalityZipCode =	'24540'	, strLocalityName =	'Pittsylvania County'	, intMasterId =	4601593
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51143'	, strLocalityZipCode =	'24541'	, strLocalityName =	'Pittsylvania County'	, intMasterId =	4601594
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51143'	, strLocalityZipCode =	'24549'	, strLocalityName =	'Pittsylvania County'	, intMasterId =	4601595
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51143'	, strLocalityZipCode =	'24557'	, strLocalityName =	'Pittsylvania County'	, intMasterId =	4601596
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51143'	, strLocalityZipCode =	'24563'	, strLocalityName =	'Pittsylvania County'	, intMasterId =	4601597
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51143'	, strLocalityZipCode =	'24565'	, strLocalityName =	'Pittsylvania County'	, intMasterId =	4601598
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51143'	, strLocalityZipCode =	'24566'	, strLocalityName =	'Pittsylvania County'	, intMasterId =	4601599
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51143'	, strLocalityZipCode =	'24569'	, strLocalityName =	'Pittsylvania County'	, intMasterId =	4601600
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51143'	, strLocalityZipCode =	'24586'	, strLocalityName =	'Pittsylvania County'	, intMasterId =	4601601
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51143'	, strLocalityZipCode =	'24594'	, strLocalityName =	'Pittsylvania County'	, intMasterId =	4601602
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51143'	, strLocalityZipCode =	'24597'	, strLocalityName =	'Pittsylvania County'	, intMasterId =	4601603
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51143'	, strLocalityZipCode =	'27326'	, strLocalityName =	'Pittsylvania County'	, intMasterId =	4601604
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51735'	, strLocalityZipCode =	'23662'	, strLocalityName =	'Poquoson, City of'	, intMasterId =	4601605
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51740'	, strLocalityZipCode =	'23701'	, strLocalityName =	'Portsmouth, City of'	, intMasterId =	4601606
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51740'	, strLocalityZipCode =	'23702'	, strLocalityName =	'Portsmouth, City of'	, intMasterId =	4601607
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51740'	, strLocalityZipCode =	'23703'	, strLocalityName =	'Portsmouth, City of'	, intMasterId =	4601608
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51740'	, strLocalityZipCode =	'23704'	, strLocalityName =	'Portsmouth, City of'	, intMasterId =	4601609
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51740'	, strLocalityZipCode =	'23707'	, strLocalityName =	'Portsmouth, City of'	, intMasterId =	4601610
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51740'	, strLocalityZipCode =	'23708'	, strLocalityName =	'Portsmouth, City of'	, intMasterId =	4601611
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51740'	, strLocalityZipCode =	'23709'	, strLocalityName =	'Portsmouth, City of'	, intMasterId =	4601612
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51145'	, strLocalityZipCode =	'23112'	, strLocalityName =	'Powhatan County'	, intMasterId =	4601613
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51145'	, strLocalityZipCode =	'23113'	, strLocalityName =	'Powhatan County'	, intMasterId =	4601614
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51145'	, strLocalityZipCode =	'23120'	, strLocalityName =	'Powhatan County'	, intMasterId =	4601615
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51145'	, strLocalityZipCode =	'23139'	, strLocalityName =	'Powhatan County'	, intMasterId =	4601616
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51145'	, strLocalityZipCode =	'23160'	, strLocalityName =	'Powhatan County'	, intMasterId =	4601617
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51147'	, strLocalityZipCode =	'23901'	, strLocalityName =	'Prince Edward County'	, intMasterId =	4601618
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51147'	, strLocalityZipCode =	'23909'	, strLocalityName =	'Prince Edward County'	, intMasterId =	4601619
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51147'	, strLocalityZipCode =	'23922'	, strLocalityName =	'Prince Edward County'	, intMasterId =	4601620
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51147'	, strLocalityZipCode =	'23923'	, strLocalityName =	'Prince Edward County'	, intMasterId =	4601621
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51147'	, strLocalityZipCode =	'23934'	, strLocalityName =	'Prince Edward County'	, intMasterId =	4601622
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51147'	, strLocalityZipCode =	'23942'	, strLocalityName =	'Prince Edward County'	, intMasterId =	4601623
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51147'	, strLocalityZipCode =	'23943'	, strLocalityName =	'Prince Edward County'	, intMasterId =	4601624
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51147'	, strLocalityZipCode =	'23947'	, strLocalityName =	'Prince Edward County'	, intMasterId =	4601625
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51147'	, strLocalityZipCode =	'23954'	, strLocalityName =	'Prince Edward County'	, intMasterId =	4601626
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51147'	, strLocalityZipCode =	'23958'	, strLocalityName =	'Prince Edward County'	, intMasterId =	4601627
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51147'	, strLocalityZipCode =	'23960'	, strLocalityName =	'Prince Edward County'	, intMasterId =	4601628
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51147'	, strLocalityZipCode =	'23966'	, strLocalityName =	'Prince Edward County'	, intMasterId =	4601629
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51149'	, strLocalityZipCode =	'23801'	, strLocalityName =	'Prince George County'	, intMasterId =	4601630
							
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51149'	, strLocalityZipCode =	'23805'	, strLocalityName =	'Prince George County'	, intMasterId =	4601631
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51149'	, strLocalityZipCode =	'23830'	, strLocalityName =	'Prince George County'	, intMasterId =	4601632
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51149'	, strLocalityZipCode =	'23842'	, strLocalityName =	'Prince George County'	, intMasterId =	4601633
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51149'	, strLocalityZipCode =	'23860'	, strLocalityName =	'Prince George County'	, intMasterId =	4601634
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51149'	, strLocalityZipCode =	'23875'	, strLocalityName =	'Prince George County'	, intMasterId =	4601635
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51149'	, strLocalityZipCode =	'23881'	, strLocalityName =	'Prince George County'	, intMasterId =	4601636
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51153'	, strLocalityZipCode =	'20109'	, strLocalityName =	'Prince William County'	, intMasterId =	4601637
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51153'	, strLocalityZipCode =	'20110'	, strLocalityName =	'Prince William County'	, intMasterId =	4601638
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51153'	, strLocalityZipCode =	'20111'	, strLocalityName =	'Prince William County'	, intMasterId =	4601639
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51153'	, strLocalityZipCode =	'20112'	, strLocalityName =	'Prince William County'	, intMasterId =	4601640
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51153'	, strLocalityZipCode =	'20119'	, strLocalityName =	'Prince William County'	, intMasterId =	4601641
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51153'	, strLocalityZipCode =	'20120'	, strLocalityName =	'Prince William County'	, intMasterId =	4601642
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51153'	, strLocalityZipCode =	'20136'	, strLocalityName =	'Prince William County'	, intMasterId =	4601643
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51153'	, strLocalityZipCode =	'20137'	, strLocalityName =	'Prince William County'	, intMasterId =	4601644
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51153'	, strLocalityZipCode =	'20143'	, strLocalityName =	'Prince William County'	, intMasterId =	4601645
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51153'	, strLocalityZipCode =	'20155'	, strLocalityName =	'Prince William County'	, intMasterId =	4601646
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51153'	, strLocalityZipCode =	'20169'	, strLocalityName =	'Prince William County'	, intMasterId =	4601647
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51153'	, strLocalityZipCode =	'20181'	, strLocalityName =	'Prince William County'	, intMasterId =	4601648
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51153'	, strLocalityZipCode =	'20182'	, strLocalityName =	'Prince William County'	, intMasterId =	4601649
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51153'	, strLocalityZipCode =	'22025'	, strLocalityName =	'Prince William County'	, intMasterId =	4601650
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51153'	, strLocalityZipCode =	'22026'	, strLocalityName =	'Prince William County'	, intMasterId =	4601651
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51153'	, strLocalityZipCode =	'22134'	, strLocalityName =	'Prince William County'	, intMasterId =	4601652
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51153'	, strLocalityZipCode =	'22135'	, strLocalityName =	'Prince William County'	, intMasterId =	4601653
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51153'	, strLocalityZipCode =	'22172'	, strLocalityName =	'Prince William County'	, intMasterId =	4601654
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51153'	, strLocalityZipCode =	'22191'	, strLocalityName =	'Prince William County'	, intMasterId =	4601655
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51153'	, strLocalityZipCode =	'22192'	, strLocalityName =	'Prince William County'	, intMasterId =	4601656
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51153'	, strLocalityZipCode =	'22193'	, strLocalityName =	'Prince William County'	, intMasterId =	4601657
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51155'	, strLocalityZipCode =	'24058'	, strLocalityName =	'Pulaski County'	, intMasterId =	4601658
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51155'	, strLocalityZipCode =	'24084'	, strLocalityName =	'Pulaski County'	, intMasterId =	4601659
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51155'	, strLocalityZipCode =	'24126'	, strLocalityName =	'Pulaski County'	, intMasterId =	4601660
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51155'	, strLocalityZipCode =	'24129'	, strLocalityName =	'Pulaski County'	, intMasterId =	4601661
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51155'	, strLocalityZipCode =	'24132'	, strLocalityName =	'Pulaski County'	, intMasterId =	4601662
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51155'	, strLocalityZipCode =	'24141'	, strLocalityName =	'Pulaski County'	, intMasterId =	4601663
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51155'	, strLocalityZipCode =	'24301'	, strLocalityName =	'Pulaski County'	, intMasterId =	4601664
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51155'	, strLocalityZipCode =	'24324'	, strLocalityName =	'Pulaski County'	, intMasterId =	4601665
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51155'	, strLocalityZipCode =	'24347'	, strLocalityName =	'Pulaski County'	, intMasterId =	4601666
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51750'	, strLocalityZipCode =	'24141'	, strLocalityName =	'Radford, City of'	, intMasterId =	4601667
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51750'	, strLocalityZipCode =	'24142'	, strLocalityName =	'Radford, City of'	, intMasterId =	4601668
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51157'	, strLocalityZipCode =	'20106'	, strLocalityName =	'Rappahannock County'	, intMasterId =	4601669
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51157'	, strLocalityZipCode =	'22623'	, strLocalityName =	'Rappahannock County'	, intMasterId =	4601670
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51157'	, strLocalityZipCode =	'22627'	, strLocalityName =	'Rappahannock County'	, intMasterId =	4601671
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51157'	, strLocalityZipCode =	'22640'	, strLocalityName =	'Rappahannock County'	, intMasterId =	4601672
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51157'	, strLocalityZipCode =	'22642'	, strLocalityName =	'Rappahannock County'	, intMasterId =	4601673
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51157'	, strLocalityZipCode =	'22713'	, strLocalityName =	'Rappahannock County'	, intMasterId =	4601674
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51157'	, strLocalityZipCode =	'22716'	, strLocalityName =	'Rappahannock County'	, intMasterId =	4601675
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51157'	, strLocalityZipCode =	'22740'	, strLocalityName =	'Rappahannock County'	, intMasterId =	4601676
							
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51157'	, strLocalityZipCode =	'22747'	, strLocalityName =	'Rappahannock County'	, intMasterId =	4601677
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51157'	, strLocalityZipCode =	'22749'	, strLocalityName =	'Rappahannock County'	, intMasterId =	4601678
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51159'	, strLocalityZipCode =	'22435'	, strLocalityName =	'Richmond County'	, intMasterId =	4601679
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51159'	, strLocalityZipCode =	'22460'	, strLocalityName =	'Richmond County'	, intMasterId =	4601680
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51159'	, strLocalityZipCode =	'22472'	, strLocalityName =	'Richmond County'	, intMasterId =	4601681
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51159'	, strLocalityZipCode =	'22473'	, strLocalityName =	'Richmond County'	, intMasterId =	4601682
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51159'	, strLocalityZipCode =	'22520'	, strLocalityName =	'Richmond County'	, intMasterId =	4601683
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51159'	, strLocalityZipCode =	'22548'	, strLocalityName =	'Richmond County'	, intMasterId =	4601684
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51159'	, strLocalityZipCode =	'22570'	, strLocalityName =	'Richmond County'	, intMasterId =	4601685
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51159'	, strLocalityZipCode =	'22572'	, strLocalityName =	'Richmond County'	, intMasterId =	4601686
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51760'	, strLocalityZipCode =	'23173'	, strLocalityName =	'Richmond, City of'	, intMasterId =	4601687
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51760'	, strLocalityZipCode =	'23218'	, strLocalityName =	'Richmond, City of'	, intMasterId =	4601688
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51760'	, strLocalityZipCode =	'23219'	, strLocalityName =	'Richmond, City of'	, intMasterId =	4601689
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51760'	, strLocalityZipCode =	'23220'	, strLocalityName =	'Richmond, City of'	, intMasterId =	4601690
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51760'	, strLocalityZipCode =	'23221'	, strLocalityName =	'Richmond, City of'	, intMasterId =	4601691
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51760'	, strLocalityZipCode =	'23222'	, strLocalityName =	'Richmond, City of'	, intMasterId =	4601692
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51760'	, strLocalityZipCode =	'23223'	, strLocalityName =	'Richmond, City of'	, intMasterId =	4601693
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51760'	, strLocalityZipCode =	'23224'	, strLocalityName =	'Richmond, City of'	, intMasterId =	4601694
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51760'	, strLocalityZipCode =	'23225'	, strLocalityName =	'Richmond, City of'	, intMasterId =	4601695
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51760'	, strLocalityZipCode =	'23226'	, strLocalityName =	'Richmond, City of'	, intMasterId =	4601696
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51760'	, strLocalityZipCode =	'23227'	, strLocalityName =	'Richmond, City of'	, intMasterId =	4601697
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51760'	, strLocalityZipCode =	'23230'	, strLocalityName =	'Richmond, City of'	, intMasterId =	4601698
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51760'	, strLocalityZipCode =	'23231'	, strLocalityName =	'Richmond, City of'	, intMasterId =	4601699
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51760'	, strLocalityZipCode =	'23232'	, strLocalityName =	'Richmond, City of'	, intMasterId =	4601700
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51760'	, strLocalityZipCode =	'23234'	, strLocalityName =	'Richmond, City of'	, intMasterId =	4601701
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51760'	, strLocalityZipCode =	'23235'	, strLocalityName =	'Richmond, City of'	, intMasterId =	4601702
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51760'	, strLocalityZipCode =	'23284'	, strLocalityName =	'Richmond, City of'	, intMasterId =	4601703
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51161'	, strLocalityZipCode =	'24012'	, strLocalityName =	'Roanoke County'	, intMasterId =	4601704
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51161'	, strLocalityZipCode =	'24014'	, strLocalityName =	'Roanoke County'	, intMasterId =	4601705
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51161'	, strLocalityZipCode =	'24018'	, strLocalityName =	'Roanoke County'	, intMasterId =	4601706
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51161'	, strLocalityZipCode =	'24019'	, strLocalityName =	'Roanoke County'	, intMasterId =	4601707
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51161'	, strLocalityZipCode =	'24020'	, strLocalityName =	'Roanoke County'	, intMasterId =	4601708
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51161'	, strLocalityZipCode =	'24050'	, strLocalityName =	'Roanoke County'	, intMasterId =	4601709
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51161'	, strLocalityZipCode =	'24059'	, strLocalityName =	'Roanoke County'	, intMasterId =	4601710
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51161'	, strLocalityZipCode =	'24065'	, strLocalityName =	'Roanoke County'	, intMasterId =	4601711
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51161'	, strLocalityZipCode =	'24070'	, strLocalityName =	'Roanoke County'	, intMasterId =	4601712
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51161'	, strLocalityZipCode =	'24087'	, strLocalityName =	'Roanoke County'	, intMasterId =	4601713
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51161'	, strLocalityZipCode =	'24153'	, strLocalityName =	'Roanoke County'	, intMasterId =	4601714
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51161'	, strLocalityZipCode =	'24175'	, strLocalityName =	'Roanoke County'	, intMasterId =	4601715
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51161'	, strLocalityZipCode =	'24179'	, strLocalityName =	'Roanoke County'	, intMasterId =	4601716
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51770'	, strLocalityZipCode =	'24011'	, strLocalityName =	'Roanoke, City of'	, intMasterId =	4601717
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51770'	, strLocalityZipCode =	'24012'	, strLocalityName =	'Roanoke, City of'	, intMasterId =	4601718
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51770'	, strLocalityZipCode =	'24013'	, strLocalityName =	'Roanoke, City of'	, intMasterId =	4601719
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51770'	, strLocalityZipCode =	'24014'	, strLocalityName =	'Roanoke, City of'	, intMasterId =	4601720
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51770'	, strLocalityZipCode =	'24015'	, strLocalityName =	'Roanoke, City of'	, intMasterId =	4601721
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51770'	, strLocalityZipCode =	'24016'	, strLocalityName =	'Roanoke, City of'	, intMasterId =	4601722
							
							
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51770'	, strLocalityZipCode =	'24017'	, strLocalityName =	'Roanoke, City of'	, intMasterId =	4601723
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51770'	, strLocalityZipCode =	'24018'	, strLocalityName =	'Roanoke, City of'	, intMasterId =	4601724
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51770'	, strLocalityZipCode =	'24019'	, strLocalityName =	'Roanoke, City of'	, intMasterId =	4601725
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51770'	, strLocalityZipCode =	'24020'	, strLocalityName =	'Roanoke, City of'	, intMasterId =	4601726
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51770'	, strLocalityZipCode =	'24155'	, strLocalityName =	'Roanoke, City of'	, intMasterId =	4601727
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51770'	, strLocalityZipCode =	'24157'	, strLocalityName =	'Roanoke, City of'	, intMasterId =	4601728
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51163'	, strLocalityZipCode =	'24066'	, strLocalityName =	'Rockbridge County'	, intMasterId =	4601729
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51163'	, strLocalityZipCode =	'24415'	, strLocalityName =	'Rockbridge County'	, intMasterId =	4601730
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51163'	, strLocalityZipCode =	'24416'	, strLocalityName =	'Rockbridge County'	, intMasterId =	4601731
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51163'	, strLocalityZipCode =	'24435'	, strLocalityName =	'Rockbridge County'	, intMasterId =	4601732
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51163'	, strLocalityZipCode =	'24439'	, strLocalityName =	'Rockbridge County'	, intMasterId =	4601733
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51163'	, strLocalityZipCode =	'24450'	, strLocalityName =	'Rockbridge County'	, intMasterId =	4601734
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51163'	, strLocalityZipCode =	'24459'	, strLocalityName =	'Rockbridge County'	, intMasterId =	4601735
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51163'	, strLocalityZipCode =	'24472'	, strLocalityName =	'Rockbridge County'	, intMasterId =	4601736
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51163'	, strLocalityZipCode =	'24473'	, strLocalityName =	'Rockbridge County'	, intMasterId =	4601737
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51163'	, strLocalityZipCode =	'24483'	, strLocalityName =	'Rockbridge County'	, intMasterId =	4601738
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51163'	, strLocalityZipCode =	'24555'	, strLocalityName =	'Rockbridge County'	, intMasterId =	4601739
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51163'	, strLocalityZipCode =	'24578'	, strLocalityName =	'Rockbridge County'	, intMasterId =	4601740
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51163'	, strLocalityZipCode =	'24579'	, strLocalityName =	'Rockbridge County'	, intMasterId =	4601741
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'22801'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601742
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'22802'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601743
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'22811'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601744
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'22812'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601745
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'22815'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601746
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'22820'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601747
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'22821'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601748
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'22827'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601749
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'22830'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601750
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'22831'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601751
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'22832'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601752
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'22833'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601753
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'22834'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601754
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'22840'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601755
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'22841'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601756
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'22844'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601757
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'22846'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601758
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'22848'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601759
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'22849'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601760
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'22850'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601761
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'22853'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601762
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'24441'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601763
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'24471'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601764
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51165'	, strLocalityZipCode =	'24486'	, strLocalityName =	'Rockingham County'	, intMasterId =	4601765
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51167'	, strLocalityZipCode =	'24224'	, strLocalityName =	'Russell County'	, intMasterId =	4601766
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51167'	, strLocalityZipCode =	'24225'	, strLocalityName =	'Russell County'	, intMasterId =	4601767
							
							
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51167'	, strLocalityZipCode =	'24237'	, strLocalityName =	'Russell County'	, intMasterId =	4601768
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51167'	, strLocalityZipCode =	'24260'	, strLocalityName =	'Russell County'	, intMasterId =	4601769
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51167'	, strLocalityZipCode =	'24266'	, strLocalityName =	'Russell County'	, intMasterId =	4601770
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51167'	, strLocalityZipCode =	'24271'	, strLocalityName =	'Russell County'	, intMasterId =	4601771
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51167'	, strLocalityZipCode =	'24280'	, strLocalityName =	'Russell County'	, intMasterId =	4601772
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51167'	, strLocalityZipCode =	'24283'	, strLocalityName =	'Russell County'	, intMasterId =	4601773
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51167'	, strLocalityZipCode =	'24609'	, strLocalityName =	'Russell County'	, intMasterId =	4601774
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51167'	, strLocalityZipCode =	'24639'	, strLocalityName =	'Russell County'	, intMasterId =	4601775
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51167'	, strLocalityZipCode =	'24649'	, strLocalityName =	'Russell County'	, intMasterId =	4601776
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51775'	, strLocalityZipCode =	'24018'	, strLocalityName =	'Salem, City of'	, intMasterId =	4601777
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51775'	, strLocalityZipCode =	'24153'	, strLocalityName =	'Salem, City of'	, intMasterId =	4601778
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51775'	, strLocalityZipCode =	'24155'	, strLocalityName =	'Salem, City of'	, intMasterId =	4601779
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51775'	, strLocalityZipCode =	'24157'	, strLocalityName =	'Salem, City of'	, intMasterId =	4601780
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51169'	, strLocalityZipCode =	'24202'	, strLocalityName =	'Scott County'	, intMasterId =	4601781
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51169'	, strLocalityZipCode =	'24221'	, strLocalityName =	'Scott County'	, intMasterId =	4601782
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51169'	, strLocalityZipCode =	'24230'	, strLocalityName =	'Scott County'	, intMasterId =	4601783
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51169'	, strLocalityZipCode =	'24244'	, strLocalityName =	'Scott County'	, intMasterId =	4601784
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51169'	, strLocalityZipCode =	'24245'	, strLocalityName =	'Scott County'	, intMasterId =	4601785
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51169'	, strLocalityZipCode =	'24250'	, strLocalityName =	'Scott County'	, intMasterId =	4601786
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51169'	, strLocalityZipCode =	'24251'	, strLocalityName =	'Scott County'	, intMasterId =	4601787
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51169'	, strLocalityZipCode =	'24258'	, strLocalityName =	'Scott County'	, intMasterId =	4601788
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51169'	, strLocalityZipCode =	'24271'	, strLocalityName =	'Scott County'	, intMasterId =	4601789
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51169'	, strLocalityZipCode =	'24290'	, strLocalityName =	'Scott County'	, intMasterId =	4601790
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51171'	, strLocalityZipCode =	'22626'	, strLocalityName =	'Shenandoah County'	, intMasterId =	4601791
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51171'	, strLocalityZipCode =	'22641'	, strLocalityName =	'Shenandoah County'	, intMasterId =	4601792
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51171'	, strLocalityZipCode =	'22644'	, strLocalityName =	'Shenandoah County'	, intMasterId =	4601793
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51171'	, strLocalityZipCode =	'22652'	, strLocalityName =	'Shenandoah County'	, intMasterId =	4601794
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51171'	, strLocalityZipCode =	'22654'	, strLocalityName =	'Shenandoah County'	, intMasterId =	4601795
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51171'	, strLocalityZipCode =	'22657'	, strLocalityName =	'Shenandoah County'	, intMasterId =	4601796
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51171'	, strLocalityZipCode =	'22660'	, strLocalityName =	'Shenandoah County'	, intMasterId =	4601797
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51171'	, strLocalityZipCode =	'22664'	, strLocalityName =	'Shenandoah County'	, intMasterId =	4601798
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51171'	, strLocalityZipCode =	'22810'	, strLocalityName =	'Shenandoah County'	, intMasterId =	4601799
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51171'	, strLocalityZipCode =	'22815'	, strLocalityName =	'Shenandoah County'	, intMasterId =	4601800
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51171'	, strLocalityZipCode =	'22824'	, strLocalityName =	'Shenandoah County'	, intMasterId =	4601801
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51171'	, strLocalityZipCode =	'22842'	, strLocalityName =	'Shenandoah County'	, intMasterId =	4601802
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51171'	, strLocalityZipCode =	'22844'	, strLocalityName =	'Shenandoah County'	, intMasterId =	4601803
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51171'	, strLocalityZipCode =	'22845'	, strLocalityName =	'Shenandoah County'	, intMasterId =	4601804
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51171'	, strLocalityZipCode =	'22847'	, strLocalityName =	'Shenandoah County'	, intMasterId =	4601805
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51171'	, strLocalityZipCode =	'22853'	, strLocalityName =	'Shenandoah County'	, intMasterId =	4601806
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51173'	, strLocalityZipCode =	'24236'	, strLocalityName =	'Smyth County'	, intMasterId =	4601807
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51173'	, strLocalityZipCode =	'24311'	, strLocalityName =	'Smyth County'	, intMasterId =	4601808
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51173'	, strLocalityZipCode =	'24318'	, strLocalityName =	'Smyth County'	, intMasterId =	4601809
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51173'	, strLocalityZipCode =	'24319'	, strLocalityName =	'Smyth County'	, intMasterId =	4601810
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51173'	, strLocalityZipCode =	'24340'	, strLocalityName =	'Smyth County'	, intMasterId =	4601811
							
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51173'	, strLocalityZipCode =	'24368'	, strLocalityName =	'Smyth County'	, intMasterId =	4601812
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51173'	, strLocalityZipCode =	'24370'	, strLocalityName =	'Smyth County'	, intMasterId =	4601813
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51173'	, strLocalityZipCode =	'24374'	, strLocalityName =	'Smyth County'	, intMasterId =	4601814
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51173'	, strLocalityZipCode =	'24375'	, strLocalityName =	'Smyth County'	, intMasterId =	4601815
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51173'	, strLocalityZipCode =	'24378'	, strLocalityName =	'Smyth County'	, intMasterId =	4601816
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51175'	, strLocalityZipCode =	'23827'	, strLocalityName =	'Southampton County'	, intMasterId =	4601817
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51175'	, strLocalityZipCode =	'23828'	, strLocalityName =	'Southampton County'	, intMasterId =	4601818
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51175'	, strLocalityZipCode =	'23829'	, strLocalityName =	'Southampton County'	, intMasterId =	4601819
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51175'	, strLocalityZipCode =	'23837'	, strLocalityName =	'Southampton County'	, intMasterId =	4601820
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51175'	, strLocalityZipCode =	'23844'	, strLocalityName =	'Southampton County'	, intMasterId =	4601821
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51175'	, strLocalityZipCode =	'23847'	, strLocalityName =	'Southampton County'	, intMasterId =	4601822
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51175'	, strLocalityZipCode =	'23851'	, strLocalityName =	'Southampton County'	, intMasterId =	4601823
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51175'	, strLocalityZipCode =	'23866'	, strLocalityName =	'Southampton County'	, intMasterId =	4601824
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51175'	, strLocalityZipCode =	'23874'	, strLocalityName =	'Southampton County'	, intMasterId =	4601825
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51175'	, strLocalityZipCode =	'23878'	, strLocalityName =	'Southampton County'	, intMasterId =	4601826
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51175'	, strLocalityZipCode =	'23888'	, strLocalityName =	'Southampton County'	, intMasterId =	4601827
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51175'	, strLocalityZipCode =	'23898'	, strLocalityName =	'Southampton County'	, intMasterId =	4601828
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51177'	, strLocalityZipCode =	'22407'	, strLocalityName =	'Spotsylvania County'	, intMasterId =	4601829
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51177'	, strLocalityZipCode =	'22408'	, strLocalityName =	'Spotsylvania County'	, intMasterId =	4601830
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51177'	, strLocalityZipCode =	'22508'	, strLocalityName =	'Spotsylvania County'	, intMasterId =	4601831
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51177'	, strLocalityZipCode =	'22534'	, strLocalityName =	'Spotsylvania County'	, intMasterId =	4601832
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51177'	, strLocalityZipCode =	'22551'	, strLocalityName =	'Spotsylvania County'	, intMasterId =	4601833
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51177'	, strLocalityZipCode =	'22553'	, strLocalityName =	'Spotsylvania County'	, intMasterId =	4601834
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51177'	, strLocalityZipCode =	'22567'	, strLocalityName =	'Spotsylvania County'	, intMasterId =	4601835
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51177'	, strLocalityZipCode =	'22580'	, strLocalityName =	'Spotsylvania County'	, intMasterId =	4601836
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51177'	, strLocalityZipCode =	'22960'	, strLocalityName =	'Spotsylvania County'	, intMasterId =	4601837
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51177'	, strLocalityZipCode =	'23015'	, strLocalityName =	'Spotsylvania County'	, intMasterId =	4601838
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51177'	, strLocalityZipCode =	'23024'	, strLocalityName =	'Spotsylvania County'	, intMasterId =	4601839
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51177'	, strLocalityZipCode =	'23117'	, strLocalityName =	'Spotsylvania County'	, intMasterId =	4601840
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51177'	, strLocalityZipCode =	'22134'	, strLocalityName =	'Stafford County'	, intMasterId =	4601841
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51179'	, strLocalityZipCode =	'22135'	, strLocalityName =	'Stafford County'	, intMasterId =	4601842
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51179'	, strLocalityZipCode =	'22405'	, strLocalityName =	'Stafford County'	, intMasterId =	4601843
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51179'	, strLocalityZipCode =	'22406'	, strLocalityName =	'Stafford County'	, intMasterId =	4601844
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51179'	, strLocalityZipCode =	'22412'	, strLocalityName =	'Stafford County'	, intMasterId =	4601845
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51179'	, strLocalityZipCode =	'22554'	, strLocalityName =	'Stafford County'	, intMasterId =	4601846
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51179'	, strLocalityZipCode =	'22556'	, strLocalityName =	'Stafford County'	, intMasterId =	4601847
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51790'	, strLocalityZipCode =	'24401'	, strLocalityName =	'Staunton, City of'	, intMasterId =	4601848
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51790'	, strLocalityZipCode =	'24402'	, strLocalityName =	'Staunton, City of'	, intMasterId =	4601849
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51790'	, strLocalityZipCode =	'24482'	, strLocalityName =	'Staunton, City of'	, intMasterId =	4601850
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51800'	, strLocalityZipCode =	'23432'	, strLocalityName =	'Suffolk, City of'	, intMasterId =	4601851
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51800'	, strLocalityZipCode =	'23433'	, strLocalityName =	'Suffolk, City of'	, intMasterId =	4601852
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51800'	, strLocalityZipCode =	'23434'	, strLocalityName =	'Suffolk, City of'	, intMasterId =	4601853
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51800'	, strLocalityZipCode =	'23435'	, strLocalityName =	'Suffolk, City of'	, intMasterId =	4601854
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51800'	, strLocalityZipCode =	'23436'	, strLocalityName =	'Suffolk, City of'	, intMasterId =	4601855
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51800'	, strLocalityZipCode =	'23437'	, strLocalityName =	'Suffolk, City of'	, intMasterId =	4601856
							
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51800'	, strLocalityZipCode =	'23438'	, strLocalityName =	'Suffolk, City of'	, intMasterId =	4601857
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51181'	, strLocalityZipCode =	'23430'	, strLocalityName =	'Surry County'	, intMasterId =	4601858
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51181'	, strLocalityZipCode =	'23839'	, strLocalityName =	'Surry County'	, intMasterId =	4601859
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51181'	, strLocalityZipCode =	'23842'	, strLocalityName =	'Surry County'	, intMasterId =	4601860
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51181'	, strLocalityZipCode =	'23846'	, strLocalityName =	'Surry County'	, intMasterId =	4601861
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51181'	, strLocalityZipCode =	'23866'	, strLocalityName =	'Surry County'	, intMasterId =	4601862
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51181'	, strLocalityZipCode =	'23881'	, strLocalityName =	'Surry County'	, intMasterId =	4601863
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51181'	, strLocalityZipCode =	'23883'	, strLocalityName =	'Surry County'	, intMasterId =	4601864
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51181'	, strLocalityZipCode =	'23888'	, strLocalityName =	'Surry County'	, intMasterId =	4601865
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51181'	, strLocalityZipCode =	'23890'	, strLocalityName =	'Surry County'	, intMasterId =	4601866
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51181'	, strLocalityZipCode =	'23899'	, strLocalityName =	'Surry County'	, intMasterId =	4601867
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51183'	, strLocalityZipCode =	'23829'	, strLocalityName =	'Sussex County'	, intMasterId =	4601868
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51183'	, strLocalityZipCode =	'23830'	, strLocalityName =	'Sussex County'	, intMasterId =	4601869
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51183'	, strLocalityZipCode =	'23837'	, strLocalityName =	'Sussex County'	, intMasterId =	4601870
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51183'	, strLocalityZipCode =	'23842'	, strLocalityName =	'Sussex County'	, intMasterId =	4601871
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51183'	, strLocalityZipCode =	'23847'	, strLocalityName =	'Sussex County'	, intMasterId =	4601872
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51183'	, strLocalityZipCode =	'23867'	, strLocalityName =	'Sussex County'	, intMasterId =	4601873
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51183'	, strLocalityZipCode =	'23878'	, strLocalityName =	'Sussex County'	, intMasterId =	4601874
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51183'	, strLocalityZipCode =	'23882'	, strLocalityName =	'Sussex County'	, intMasterId =	4601875
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51183'	, strLocalityZipCode =	'23884'	, strLocalityName =	'Sussex County'	, intMasterId =	4601876
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51183'	, strLocalityZipCode =	'23888'	, strLocalityName =	'Sussex County'	, intMasterId =	4601877
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51183'	, strLocalityZipCode =	'23890'	, strLocalityName =	'Sussex County'	, intMasterId =	4601878
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51183'	, strLocalityZipCode =	'23891'	, strLocalityName =	'Sussex County'	, intMasterId =	4601879
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51183'	, strLocalityZipCode =	'23897'	, strLocalityName =	'Sussex County'	, intMasterId =	4601880
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51185'	, strLocalityZipCode =	'24314'	, strLocalityName =	'Tazewell County'	, intMasterId =	4601881
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51185'	, strLocalityZipCode =	'24316'	, strLocalityName =	'Tazewell County'	, intMasterId =	4601882
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51185'	, strLocalityZipCode =	'24377'	, strLocalityName =	'Tazewell County'	, intMasterId =	4601883
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51185'	, strLocalityZipCode =	'24601'	, strLocalityName =	'Tazewell County'	, intMasterId =	4601884
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51185'	, strLocalityZipCode =	'24602'	, strLocalityName =	'Tazewell County'	, intMasterId =	4601885
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51185'	, strLocalityZipCode =	'24604'	, strLocalityName =	'Tazewell County'	, intMasterId =	4601886
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51185'	, strLocalityZipCode =	'24605'	, strLocalityName =	'Tazewell County'	, intMasterId =	4601887
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51185'	, strLocalityZipCode =	'24606'	, strLocalityName =	'Tazewell County'	, intMasterId =	4601888
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51185'	, strLocalityZipCode =	'24608'	, strLocalityName =	'Tazewell County'	, intMasterId =	4601889
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51185'	, strLocalityZipCode =	'24609'	, strLocalityName =	'Tazewell County'	, intMasterId =	4601890
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51185'	, strLocalityZipCode =	'24612'	, strLocalityName =	'Tazewell County'	, intMasterId =	4601891
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51185'	, strLocalityZipCode =	'24613'	, strLocalityName =	'Tazewell County'	, intMasterId =	4601892
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51185'	, strLocalityZipCode =	'24619'	, strLocalityName =	'Tazewell County'	, intMasterId =	4601893
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51185'	, strLocalityZipCode =	'24622'	, strLocalityName =	'Tazewell County'	, intMasterId =	4601894
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51185'	, strLocalityZipCode =	'24630'	, strLocalityName =	'Tazewell County'	, intMasterId =	4601895
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51185'	, strLocalityZipCode =	'24635'	, strLocalityName =	'Tazewell County'	, intMasterId =	4601896
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51185'	, strLocalityZipCode =	'24637'	, strLocalityName =	'Tazewell County'	, intMasterId =	4601897
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51185'	, strLocalityZipCode =	'24639'	, strLocalityName =	'Tazewell County'	, intMasterId =	4601898
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51185'	, strLocalityZipCode =	'24640'	, strLocalityName =	'Tazewell County'	, intMasterId =	4601899
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51185'	, strLocalityZipCode =	'24641'	, strLocalityName =	'Tazewell County'	, intMasterId =	4601900
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51185'	, strLocalityZipCode =	'24651'	, strLocalityName =	'Tazewell County'	, intMasterId =	4601901
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51810'	, strLocalityZipCode =	'23521'	, strLocalityName =	'Virginia Beach, City of'	, intMasterId =	4601902
							
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51810'	, strLocalityZipCode =	'23452'	, strLocalityName =	'Virginia Beach, City of'	, intMasterId =	4601903
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51810'	, strLocalityZipCode =	'23453'	, strLocalityName =	'Virginia Beach, City of'	, intMasterId =	4601904
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51810'	, strLocalityZipCode =	'23454'	, strLocalityName =	'Virginia Beach, City of'	, intMasterId =	4601905
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51810'	, strLocalityZipCode =	'23455'	, strLocalityName =	'Virginia Beach, City of'	, intMasterId =	4601906
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51810'	, strLocalityZipCode =	'23456'	, strLocalityName =	'Virginia Beach, City of'	, intMasterId =	4601907
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51810'	, strLocalityZipCode =	'23457'	, strLocalityName =	'Virginia Beach, City of'	, intMasterId =	4601908
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51810'	, strLocalityZipCode =	'23459'	, strLocalityName =	'Virginia Beach, City of'	, intMasterId =	4601909
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51810'	, strLocalityZipCode =	'23460'	, strLocalityName =	'Virginia Beach, City of'	, intMasterId =	4601910
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51810'	, strLocalityZipCode =	'23461'	, strLocalityName =	'Virginia Beach, City of'	, intMasterId =	4601911
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51810'	, strLocalityZipCode =	'23462'	, strLocalityName =	'Virginia Beach, City of'	, intMasterId =	4601912
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51810'	, strLocalityZipCode =	'23463'	, strLocalityName =	'Virginia Beach, City of'	, intMasterId =	4601913
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51810'	, strLocalityZipCode =	'23464'	, strLocalityName =	'Virginia Beach, City of'	, intMasterId =	4601914
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51810'	, strLocalityZipCode =	'23465'	, strLocalityName =	'Virginia Beach, City of'	, intMasterId =	4601915
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51810'	, strLocalityZipCode =	'23479'	, strLocalityName =	'Virginia Beach, City of'	, intMasterId =	4601916
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51187'	, strLocalityZipCode =	'22610'	, strLocalityName =	'Warren County'	, intMasterId =	4601917
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51187'	, strLocalityZipCode =	'22630'	, strLocalityName =	'Warren County'	, intMasterId =	4601918
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51187'	, strLocalityZipCode =	'22642'	, strLocalityName =	'Warren County'	, intMasterId =	4601919
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51187'	, strLocalityZipCode =	'22645'	, strLocalityName =	'Warren County'	, intMasterId =	4601920
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51187'	, strLocalityZipCode =	'22655'	, strLocalityName =	'Warren County'	, intMasterId =	4601921
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51187'	, strLocalityZipCode =	'22657'	, strLocalityName =	'Warren County'	, intMasterId =	4601922
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51187'	, strLocalityZipCode =	'22663'	, strLocalityName =	'Warren County'	, intMasterId =	4601923
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51191'	, strLocalityZipCode =	'24202'	, strLocalityName =	'Washington County'	, intMasterId =	4601924
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51191'	, strLocalityZipCode =	'24210'	, strLocalityName =	'Washington County'	, intMasterId =	4601925
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51191'	, strLocalityZipCode =	'24211'	, strLocalityName =	'Washington County'	, intMasterId =	4601926
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51191'	, strLocalityZipCode =	'24236'	, strLocalityName =	'Washington County'	, intMasterId =	4601927
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51191'	, strLocalityZipCode =	'24270'	, strLocalityName =	'Washington County'	, intMasterId =	4601928
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51191'	, strLocalityZipCode =	'24319'	, strLocalityName =	'Washington County'	, intMasterId =	4601929
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51191'	, strLocalityZipCode =	'24340'	, strLocalityName =	'Washington County'	, intMasterId =	4601930
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51191'	, strLocalityZipCode =	'24361'	, strLocalityName =	'Washington County'	, intMasterId =	4601931
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51191'	, strLocalityZipCode =	'24370'	, strLocalityName =	'Washington County'	, intMasterId =	4601932
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51820'	, strLocalityZipCode =	'22952'	, strLocalityName =	'Waynesboro, City of'	, intMasterId =	4601933
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51820'	, strLocalityZipCode =	'22980'	, strLocalityName =	'Waynesboro, City of'	, intMasterId =	4601934
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51193'	, strLocalityZipCode =	'22435'	, strLocalityName =	'Westmoreland County'	, intMasterId =	4601935
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51193'	, strLocalityZipCode =	'22442'	, strLocalityName =	'Westmoreland County'	, intMasterId =	4601936
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51193'	, strLocalityZipCode =	'22443'	, strLocalityName =	'Westmoreland County'	, intMasterId =	4601937
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51193'	, strLocalityZipCode =	'22469'	, strLocalityName =	'Westmoreland County'	, intMasterId =	4601938
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51193'	, strLocalityZipCode =	'22485'	, strLocalityName =	'Westmoreland County'	, intMasterId =	4601939
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51193'	, strLocalityZipCode =	'22488'	, strLocalityName =	'Westmoreland County'	, intMasterId =	4601940
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51193'	, strLocalityZipCode =	'22520'	, strLocalityName =	'Westmoreland County'	, intMasterId =	4601941
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51193'	, strLocalityZipCode =	'22524'	, strLocalityName =	'Westmoreland County'	, intMasterId =	4601942
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51193'	, strLocalityZipCode =	'22529'	, strLocalityName =	'Westmoreland County'	, intMasterId =	4601943
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51193'	, strLocalityZipCode =	'22558'	, strLocalityName =	'Westmoreland County'	, intMasterId =	4601944
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51193'	, strLocalityZipCode =	'22572'	, strLocalityName =	'Westmoreland County'	, intMasterId =	4601945
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51193'	, strLocalityZipCode =	'22577'	, strLocalityName =	'Westmoreland County'	, intMasterId =	4601946
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51193'	, strLocalityZipCode =	'22581'	, strLocalityName =	'Westmoreland County'	, intMasterId =	4601947
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51830'	, strLocalityZipCode =	'23185'	, strLocalityName =	'Williamsburg, City of'	, intMasterId =	4601948
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51830'	, strLocalityZipCode =	'23186'	, strLocalityName =	'Williamsburg, City of'	, intMasterId =	4601949
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51830'	, strLocalityZipCode =	'23188'	, strLocalityName =	'Williamsburg, City of'	, intMasterId =	4601950
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51840'	, strLocalityZipCode =	'22601'	, strLocalityName =	'Winchester, City of'	, intMasterId =	4601951
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51195'	, strLocalityZipCode =	'24215'	, strLocalityName =	'Wise County'	, intMasterId =	4601952
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51195'	, strLocalityZipCode =	'24216'	, strLocalityName =	'Wise County'	, intMasterId =	4601953
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51195'	, strLocalityZipCode =	'24219'	, strLocalityName =	'Wise County'	, intMasterId =	4601954
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51195'	, strLocalityZipCode =	'24230'	, strLocalityName =	'Wise County'	, intMasterId =	4601955
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51195'	, strLocalityZipCode =	'24246'	, strLocalityName =	'Wise County'	, intMasterId =	4601956
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51195'	, strLocalityZipCode =	'24273'	, strLocalityName =	'Wise County'	, intMasterId =	4601957
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51195'	, strLocalityZipCode =	'24279'	, strLocalityName =	'Wise County'	, intMasterId =	4601958
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51195'	, strLocalityZipCode =	'24283'	, strLocalityName =	'Wise County'	, intMasterId =	4601959
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51195'	, strLocalityZipCode =	'24293'	, strLocalityName =	'Wise County'	, intMasterId =	4601960
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51197'	, strLocalityZipCode =	'24312'	, strLocalityName =	'Wythe County'	, intMasterId =	4601961
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51197'	, strLocalityZipCode =	'24313'	, strLocalityName =	'Wythe County'	, intMasterId =	4601962
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51197'	, strLocalityZipCode =	'24322'	, strLocalityName =	'Wythe County'	, intMasterId =	4601963
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51197'	, strLocalityZipCode =	'24323'	, strLocalityName =	'Wythe County'	, intMasterId =	4601964
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51197'	, strLocalityZipCode =	'24324'	, strLocalityName =	'Wythe County'	, intMasterId =	4601965
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51197'	, strLocalityZipCode =	'24343'	, strLocalityName =	'Wythe County'	, intMasterId =	4601966
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51197'	, strLocalityZipCode =	'24350'	, strLocalityName =	'Wythe County'	, intMasterId =	4601967
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51197'	, strLocalityZipCode =	'24360'	, strLocalityName =	'Wythe County'	, intMasterId =	4601968
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51197'	, strLocalityZipCode =	'24368'	, strLocalityName =	'Wythe County'	, intMasterId =	4601969
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51197'	, strLocalityZipCode =	'24374'	, strLocalityName =	'Wythe County'	, intMasterId =	4601970
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51197'	, strLocalityZipCode =	'24382'	, strLocalityName =	'Wythe County'	, intMasterId =	4601971
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51199'	, strLocalityZipCode =	'23185'	, strLocalityName =	'York County'	, intMasterId =	4601972
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51199'	, strLocalityZipCode =	'23188'	, strLocalityName =	'York County'	, intMasterId =	4601973
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51199'	, strLocalityZipCode =	'23602'	, strLocalityName =	'York County'	, intMasterId =	4601974
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51199'	, strLocalityZipCode =	'23603'	, strLocalityName =	'York County'	, intMasterId =	4601975
							
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51199'	, strLocalityZipCode =	'23690'	, strLocalityName =	'York County'	, intMasterId =	4601976
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51199'	, strLocalityZipCode =	'23691'	, strLocalityName =	'York County'	, intMasterId =	4601977
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51199'	, strLocalityZipCode =	'23692'	, strLocalityName =	'York County'	, intMasterId =	4601978
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51199'	, strLocalityZipCode =	'23693'	, strLocalityName =	'York County'	, intMasterId =	4601979
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51199'	, strLocalityZipCode =	'23696'	, strLocalityName =	'York County'	, intMasterId =	4601980

UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51173'	, strLocalityZipCode =	'24354'	, strLocalityName =	'Smyth County'	, intMasterId =	4601981
UNION ALL SELECT intLocalityId = 0, strLocalityCode =	'51810'	, strLocalityZipCode =	'23451'	, strLocalityName =	'Virginia Beach, City of'	, intMasterId =	4601982

EXEC uspTFUpgradeLocality @TaxAuthorityCode = 'VA', @Locality = @TFLocalityVA

DELETE @TFLocalityVA
GO
