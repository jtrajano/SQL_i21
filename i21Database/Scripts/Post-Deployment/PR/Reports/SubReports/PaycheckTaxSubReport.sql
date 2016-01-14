﻿PRINT('/*******************  BEGIN Deploy the sub report *******************/')
GO

DECLARE @intReportId AS INT
DECLARE @intGroupSort AS INT
DECLARE @intNameSort AS INT

-- Delete the report data for replacement. 
SELECT	@intReportId = [intReportId]
FROM	[dbo].[tblRMReport] 
WHERE	[strName] = N'Paycheck Tax Sub Report'

-- Delete the existing sub report filter 
DELETE	[dbo].[tblRMSubreportFilter]
FROM	[dbo].[tblRMSubreportSetting] RPT_SETTING INNER JOIN [dbo].[tblRMSubreportFilter] RPT_FILTER
			ON RPT_SETTING.intSubreportSettingId = RPT_FILTER.intSubreportSettingId
WHERE	RPT_SETTING.intReportId = @intReportId

-- Delete the existing sub report condition
DELETE	[dbo].[tblRMSubreportCondition]
FROM	[dbo].[tblRMSubreportSetting] RPT_SETTING INNER JOIN [dbo].[tblRMSubreportCondition] RPT_CONDITION
			ON RPT_SETTING.intSubreportSettingId = RPT_CONDITION.intSubreportSettingId
WHERE	RPT_SETTING.intReportId = @intReportId

-- Delete the existing sub report settings. 
DELETE FROM [dbo].[tblRMSubreportSetting]
WHERE [intReportId] = @intReportId

-- Delete the default option
DELETE FROM [dbo].[tblRMDefaultOption]
WHERE [intReportId] = @intReportId

-- Delete the default filter
DELETE FROM [dbo].[tblRMDefaultFilter]
WHERE [intReportId] = @intReportId

-- Delete the default sort
DELETE FROM [dbo].[tblRMDefaultSort]
WHERE [intReportId] = @intReportId

-- Delete the criteria fields 
DELETE FROM [dbo].[tblRMCriteriaField]
WHERE [intReportId] = @intReportId

-- Delete the data source
DELETE FROM [dbo].[tblRMDatasource] 
WHERE [intReportId] = @intReportId

-- Delete the report data 
DELETE	FROM [dbo].[tblRMReport] 
WHERE	[intReportId] = @intReportId

-- Get the initial values for the sort fields
SELECT	@intGroupSort = MAX([intGroupSort]),
		@intNameSort = MAX([intNameSort])
FROM	[dbo].[tblRMReport]
WHERE	[strGroup] = N'Sub Report'

IF (@intGroupSort IS NULL)
BEGIN 
	SELECT	@intGroupSort = ISNULL(MAX([intGroupSort]), 0) + 1
	FROM	[dbo].[tblRMReport]
END 

-- Setup for the report layout
INSERT [dbo].[tblRMReport] (
	[blbLayout], 
	[strName], 
	[strGroup], 
	[strBuilderServiceAddress], 
	[strWebViewerAddress], 
	[ysnAllowChangeFieldname], 
	[ysnAllowRemoveFieldname], 
	[ysnAllowAddFieldname], 
	[ysnAllowArchive], 
	[ysnUseAllAndOperator], 
	[ysnShowQuery], 
	[strDescription], 
	[intCompanyInformationId], 
	[intGroupSort], 
	[intNameSort], 
	[intConcurrencyId]
) 
SELECT	
	[blbLayout] = 0x2F2F2F203C585254797065496E666F3E0D0A2F2F2F2020203C417373656D626C7946756C6C4E616D653E446576457870726573732E587472615265706F7274732E7631322E312C2056657273696F6E3D31322E312E372E302C2043756C747572653D6E65757472616C2C205075626C69634B6579546F6B656E3D623838643137353464373030653439613C2F417373656D626C7946756C6C4E616D653E0D0A2F2F2F2020203C417373656D626C794C6F636174696F6E3E433A5C4163755C5265706F727444657369676E65725C446576457870726573732E587472615265706F7274732E7631322E312E646C6C3C2F417373656D626C794C6F636174696F6E3E0D0A2F2F2F2020203C547970654E616D653E446576457870726573732E587472615265706F7274732E55492E587472615265706F72743C2F547970654E616D653E0D0A2F2F2F2020203C4C6F63616C697A6174696F6E3E656E2D55533C2F4C6F63616C697A6174696F6E3E0D0A2F2F2F203C2F585254797065496E666F3E0D0A6E616D65737061636520587472615265706F727453657269616C697A6174696F6E207B0D0A202020200D0A202020207075626C696320636C61737320587472615265706F7274203A20446576457870726573732E587472615265706F7274732E55492E587472615265706F7274207B0D0A20202020202020207072697661746520446576457870726573732E587472615265706F7274732E55492E546F704D617267696E42616E6420746F704D617267696E42616E64313B0D0A20202020202020207072697661746520446576457870726573732E587472615265706F7274732E55492E44657461696C42616E642064657461696C42616E64313B0D0A20202020202020207072697661746520446576457870726573732E587472615265706F7274732E55492E58524C6162656C206C6162656C353B0D0A20202020202020207072697661746520446576457870726573732E587472615265706F7274732E55492E58524C6162656C206C6162656C343B0D0A20202020202020207072697661746520446576457870726573732E587472615265706F7274732E55492E58524C6162656C206C6162656C333B0D0A20202020202020207072697661746520446576457870726573732E587472615265706F7274732E55492E426F74746F6D4D617267696E42616E6420626F74746F6D4D617267696E42616E64313B0D0A20202020202020207072697661746520446576457870726573732E587472615265706F7274732E55492E5265706F727448656164657242616E64205265706F72744865616465723B0D0A20202020202020207072697661746520446576457870726573732E587472615265706F7274732E55492E58524C6162656C206C6162656C323B0D0A20202020202020207072697661746520446576457870726573732E587472615265706F7274732E55492E58524C6162656C206C6162656C313B0D0A20202020202020207072697661746520446576457870726573732E587472615265706F7274732E55492E58524C6162656C206C6162656C31313B0D0A2020202020202020707269766174652053797374656D2E5265736F75726365732E5265736F757263654D616E61676572205F7265736F75726365733B0D0A20202020202020207075626C696320587472615265706F72742829207B0D0A202020202020202020202020746869732E496E697469616C697A65436F6D706F6E656E7428293B0D0A20202020202020207D0D0A2020202020202020707269766174652053797374656D2E5265736F75726365732E5265736F757263654D616E61676572207265736F7572636573207B0D0A202020202020202020202020676574207B0D0A20202020202020202020202020202020696620285F7265736F7572636573203D3D206E756C6C29207B0D0A2020202020202020202020202020202020202020737472696E67207265736F75726365537472696E67203D20227A73727676674541414143524141414162464E356333526C625335535A584E7664584A6A5A584D75556D567A62335679593256535A57466B5A5849734947317A5932397962476C694C4342575A584A7A6122202B0D0A20202020202020202020202020202020202020202020202022573975505451754D4334774C6A417349454E3162485231636D5539626D563164484A68624377675548566962476C6A53325635564739725A573439596A63335954566A4E5459784F544D305A5441344F22202B0D0A20202020202020202020202020202020202020202020202022534E5465584E305A573075556D567A623356795932567A4C6C4A31626E5270625756535A584E7664584A6A5A564E6C64414941414141424141414141414141414642425246424252464131343173654122202B0D0A20202020202020202020202020202020202020202020202022414141414F3041414141734A414230414767416151427A41433441524142684148514159514254414738416451427941474D415A51425441474D416141426C4147304159514141414141414163414A5022202B0D0A2020202020202020202020202020202020202020202020202244393462577767646D567963326C76626A30694D533477496A382B44516F3865484D3663324E6F5A57316849476C6B50534A526457567965564E6A614756745953496765473173626E4D39496949676522202B0D0A20202020202020202020202020202020202020202020202022473173626E4D3665484D39496D6830644841364C79393364336375647A4D7562334A6E4C7A49774D4445765745314D55324E6F5A5731684969423462577875637A70746332526864474539496E56796222202B0D0A202020202020202020202020202020202020202020202020226A707A5932686C6257467A4C57317059334A766332396D6443316A62323036654731734C57317A5A4746305953492B44516F6749447834637A706C624756745A5735304947356862575539496C46315A22202B0D0A20202020202020202020202020202020202020202020202022584A3555324E6F5A57316849694274633252686447453653584E45595852685532563050534A30636E566C49694274633252686447453656584E6C51335679636D567564457876593246735A5430696422202B0D0A20202020202020202020202020202020202020202020202022484A315A53492B44516F67494341675048687A4F6D4E76625842735A5868556558426C5067304B49434167494341675048687A4F6D4E6F62326C6A5A5342746157355059324E31636E4D39496A41694922202B0D0A202020202020202020202020202020202020202020202020224731686545396A59335679637A306964573569623356755A47566B496A344E4369416749434167494341675048687A4F6D56735A57316C626E5167626D46745A5430695247463059555A705A57786B6322202B0D0A2020202020202020202020202020202020202020202020202279492B44516F674943416749434167494341675048687A4F6D4E76625842735A5868556558426C5067304B494341674943416749434167494341675048687A4F6E4E6C6358566C626D4E6C5067304B4922202B0D0A202020202020202020202020202020202020202020202020224341674943416749434167494341674943413865484D365A57786C62575675644342755957316C50534A70626E525159586C6A6147566A61306C6B496942306558426C50534A34637A7070626E51694922202B0D0A20202020202020202020202020202020202020202020202022473170626B396A59335679637A30694D4349674C7A344E43694167494341674943416749434167494341675048687A4F6D56735A57316C626E5167626D46745A5430696333527956474634535751695022202B0D0A2020202020202020202020202020202020202020202020202267304B494341674943416749434167494341674943416749447834637A707A61573177624756556558426C5067304B4943416749434167494341674943416749434167494341675048687A4F6E4A6C6322202B0D0A2020202020202020202020202020202020202020202020202233527961574E306157397549474A6863325539496E687A4F6E4E30636D6C755A79492B44516F6749434167494341674943416749434167494341674943416749447834637A70745958684D5A57356E6422202B0D0A20202020202020202020202020202020202020202020202022476767646D467364575539496A5577496941765067304B49434167494341674943416749434167494341674943416750433934637A70795A584E30636D6C6A64476C76626A344E43694167494341674922202B0D0A202020202020202020202020202020202020202020202020224341674943416749434167494341384C33687A4F6E4E70625842735A5652356347552B44516F67494341674943416749434167494341674944777665484D365A57786C625756756444344E436941674922202B0D0A202020202020202020202020202020202020202020202020224341674943416749434167494341675048687A4F6D56735A57316C626E5167626D46745A5430695A474A7356473930595777694948523563475539496E687A4F6D526C59326C74595777694943382B4422202B0D0A20202020202020202020202020202020202020202020202022516F674943416749434167494341674943416749447834637A706C624756745A5735304947356862575539496D5269624652766447467357565245496942306558426C50534A34637A706B5A574E706222202B0D0A20202020202020202020202020202020202020202020202022574673496942746157355059324E31636E4D39496A41694943382B44516F67494341674943416749434167494341384C33687A4F6E4E6C6358566C626D4E6C5067304B4943416749434167494341674922202B0D0A2020202020202020202020202020202020202020202020202244777665484D36593239746347786C654652356347552B44516F6749434167494341674944777665484D365A57786C625756756444344E43694167494341674944777665484D365932687661574E6C5022202B0D0A2020202020202020202020202020202020202020202020202267304B494341674944777665484D36593239746347786C654652356347552B44516F67494341675048687A4F6E5675615846315A5342755957316C50534A446232357A64484A68615735304D53492B4422202B0D0A20202020202020202020202020202020202020202020202022516F67494341674943413865484D36633256735A574E30623349676548426864476739496934764C30526864474647615756735A484D694943382B44516F67494341674943413865484D365A6D6C6C6222202B0D0A202020202020202020202020202020202020202020202020224751676548426864476739496D6C756446426865574E6F5A574E72535751694943382B44516F674943416750433934637A7031626D6C786457552B44516F674944777665484D365A57786C625756756422202B0D0A2020202020202020202020202020202020202020202020202244344E436A777665484D3663324E6F5A57316850673D3D223B0D0A2020202020202020202020202020202020202020746869732E5F7265736F7572636573203D206E657720446576457870726573732E587472615265706F7274732E53657269616C697A6174696F6E2E58525265736F757263654D616E61676572287265736F75726365537472696E67293B0D0A202020202020202020202020202020207D0D0A2020202020202020202020202020202072657475726E20746869732E5F7265736F75726365733B0D0A2020202020202020202020207D0D0A20202020202020207D0D0A20202020202020207072697661746520766F696420496E697469616C697A65436F6D706F6E656E742829207B0D0A202020202020202020202020746869732E746F704D617267696E42616E6431203D206E657720446576457870726573732E587472615265706F7274732E55492E546F704D617267696E42616E6428293B0D0A202020202020202020202020746869732E64657461696C42616E6431203D206E657720446576457870726573732E587472615265706F7274732E55492E44657461696C42616E6428293B0D0A202020202020202020202020746869732E626F74746F6D4D617267696E42616E6431203D206E657720446576457870726573732E587472615265706F7274732E55492E426F74746F6D4D617267696E42616E6428293B0D0A202020202020202020202020746869732E5265706F7274486561646572203D206E657720446576457870726573732E587472615265706F7274732E55492E5265706F727448656164657242616E6428293B0D0A202020202020202020202020746869732E6C6162656C35203D206E657720446576457870726573732E587472615265706F7274732E55492E58524C6162656C28293B0D0A202020202020202020202020746869732E6C6162656C34203D206E657720446576457870726573732E587472615265706F7274732E55492E58524C6162656C28293B0D0A202020202020202020202020746869732E6C6162656C33203D206E657720446576457870726573732E587472615265706F7274732E55492E58524C6162656C28293B0D0A202020202020202020202020746869732E6C6162656C32203D206E657720446576457870726573732E587472615265706F7274732E55492E58524C6162656C28293B0D0A202020202020202020202020746869732E6C6162656C31203D206E657720446576457870726573732E587472615265706F7274732E55492E58524C6162656C28293B0D0A202020202020202020202020746869732E6C6162656C3131203D206E657720446576457870726573732E587472615265706F7274732E55492E58524C6162656C28293B0D0A202020202020202020202020282853797374656D2E436F6D706F6E656E744D6F64656C2E49537570706F7274496E697469616C697A6529287468697329292E426567696E496E697428293B0D0A2020202020202020202020202F2F200D0A2020202020202020202020202F2F20746F704D617267696E42616E64310D0A2020202020202020202020202F2F200D0A202020202020202020202020746869732E746F704D617267696E42616E64312E48656967687446203D2030463B0D0A202020202020202020202020746869732E746F704D617267696E42616E64312E4E616D65203D2022746F704D617267696E42616E6431223B0D0A2020202020202020202020202F2F200D0A2020202020202020202020202F2F2064657461696C42616E64310D0A2020202020202020202020202F2F200D0A202020202020202020202020746869732E64657461696C42616E64312E436F6E74726F6C732E41646452616E6765286E657720446576457870726573732E587472615265706F7274732E55492E5852436F6E74726F6C5B5D207B0D0A202020202020202020202020202020202020202020202020746869732E6C6162656C352C0D0A202020202020202020202020202020202020202020202020746869732E6C6162656C342C0D0A202020202020202020202020202020202020202020202020746869732E6C6162656C337D293B0D0A202020202020202020202020746869732E64657461696C42616E64312E48656967687446203D203134463B0D0A202020202020202020202020746869732E64657461696C42616E64312E4E616D65203D202264657461696C42616E6431223B0D0A2020202020202020202020202F2F200D0A2020202020202020202020202F2F20626F74746F6D4D617267696E42616E64310D0A2020202020202020202020202F2F200D0A202020202020202020202020746869732E626F74746F6D4D617267696E42616E64312E48656967687446203D2030463B0D0A202020202020202020202020746869732E626F74746F6D4D617267696E42616E64312E4E616D65203D2022626F74746F6D4D617267696E42616E6431223B0D0A2020202020202020202020202F2F200D0A2020202020202020202020202F2F205265706F72744865616465720D0A2020202020202020202020202F2F200D0A202020202020202020202020746869732E5265706F72744865616465722E436F6E74726F6C732E41646452616E6765286E657720446576457870726573732E587472615265706F7274732E55492E5852436F6E74726F6C5B5D207B0D0A202020202020202020202020202020202020202020202020746869732E6C6162656C322C0D0A202020202020202020202020202020202020202020202020746869732E6C6162656C312C0D0A202020202020202020202020202020202020202020202020746869732E6C6162656C31317D293B0D0A202020202020202020202020746869732E5265706F72744865616465722E48656967687446203D203333463B0D0A202020202020202020202020746869732E5265706F72744865616465722E4E616D65203D20225265706F7274486561646572223B0D0A2020202020202020202020202F2F200D0A2020202020202020202020202F2F206C6162656C350D0A2020202020202020202020202F2F200D0A202020202020202020202020746869732E6C6162656C352E43616E47726F77203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C352E4461746142696E64696E67732E41646452616E6765286E657720446576457870726573732E587472615265706F7274732E55492E585242696E64696E675B5D207B0D0A2020202020202020202020202020202020202020202020206E657720446576457870726573732E587472615265706F7274732E55492E585242696E64696E67282254657874222C206E756C6C2C2022446174614669656C64732E64626C546F74616C595444222C20227B303A232C2323302E30307D22297D293B0D0A202020202020202020202020746869732E6C6162656C352E466F6E74203D206E65772053797374656D2E44726177696E672E466F6E742822417269616C222C203846293B0D0A202020202020202020202020746869732E6C6162656C352E4C6F636174696F6E466C6F6174203D206E657720446576457870726573732E5574696C732E506F696E74466C6F6174283138352E3833462C203046293B0D0A202020202020202020202020746869732E6C6162656C352E4E616D65203D20226C6162656C35223B0D0A202020202020202020202020746869732E6C6162656C352E50616464696E67203D206E657720446576457870726573732E587472615072696E74696E672E50616464696E67496E666F28322C20322C20302C20302C2031303046293B0D0A202020202020202020202020746869732E6C6162656C352E53697A6546203D206E65772053797374656D2E44726177696E672E53697A65462836312E3137462C2031322E3546293B0D0A202020202020202020202020746869732E6C6162656C352E5374796C655072696F726974792E557365466F6E74203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C352E5374796C655072696F726974792E55736554657874416C69676E6D656E74203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C352E54657874203D20226C6162656C35223B0D0A202020202020202020202020746869732E6C6162656C352E54657874416C69676E6D656E74203D20446576457870726573732E587472615072696E74696E672E54657874416C69676E6D656E742E546F7052696768743B0D0A2020202020202020202020202F2F200D0A2020202020202020202020202F2F206C6162656C340D0A2020202020202020202020202F2F200D0A202020202020202020202020746869732E6C6162656C342E43616E47726F77203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C342E4461746142696E64696E67732E41646452616E6765286E657720446576457870726573732E587472615265706F7274732E55492E585242696E64696E675B5D207B0D0A2020202020202020202020202020202020202020202020206E657720446576457870726573732E587472615265706F7274732E55492E585242696E64696E67282254657874222C206E756C6C2C2022446174614669656C64732E64626C546F74616C222C20227B303A232C2323302E30307D22297D293B0D0A202020202020202020202020746869732E6C6162656C342E466F6E74203D206E65772053797374656D2E44726177696E672E466F6E742822417269616C222C203846293B0D0A202020202020202020202020746869732E6C6162656C342E4C6F636174696F6E466C6F6174203D206E657720446576457870726573732E5574696C732E506F696E74466C6F617428313131462C203046293B0D0A202020202020202020202020746869732E6C6162656C342E4E616D65203D20226C6162656C34223B0D0A202020202020202020202020746869732E6C6162656C342E50616464696E67203D206E657720446576457870726573732E587472615072696E74696E672E50616464696E67496E666F28322C20322C20302C20302C2031303046293B0D0A202020202020202020202020746869732E6C6162656C342E53697A6546203D206E65772053797374656D2E44726177696E672E53697A65462836392E3833462C2031322E3546293B0D0A202020202020202020202020746869732E6C6162656C342E5374796C655072696F726974792E557365466F6E74203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C342E5374796C655072696F726974792E55736554657874416C69676E6D656E74203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C342E54657874203D20226C6162656C34223B0D0A202020202020202020202020746869732E6C6162656C342E54657874416C69676E6D656E74203D20446576457870726573732E587472615072696E74696E672E54657874416C69676E6D656E742E546F7052696768743B0D0A2020202020202020202020202F2F200D0A2020202020202020202020202F2F206C6162656C330D0A2020202020202020202020202F2F200D0A202020202020202020202020746869732E6C6162656C332E43616E47726F77203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C332E4461746142696E64696E67732E41646452616E6765286E657720446576457870726573732E587472615265706F7274732E55492E585242696E64696E675B5D207B0D0A2020202020202020202020202020202020202020202020206E657720446576457870726573732E587472615265706F7274732E55492E585242696E64696E67282254657874222C206E756C6C2C2022446174614669656C64732E737472546178494422297D293B0D0A202020202020202020202020746869732E6C6162656C332E466F6E74203D206E65772053797374656D2E44726177696E672E466F6E742822417269616C222C203846293B0D0A202020202020202020202020746869732E6C6162656C332E4C6F636174696F6E466C6F6174203D206E657720446576457870726573732E5574696C732E506F696E74466C6F617428352E303030303033462C203046293B0D0A202020202020202020202020746869732E6C6162656C332E4E616D65203D20226C6162656C33223B0D0A202020202020202020202020746869732E6C6162656C332E50616464696E67203D206E657720446576457870726573732E587472615072696E74696E672E50616464696E67496E666F28322C20322C20302C20302C2031303046293B0D0A202020202020202020202020746869732E6C6162656C332E53697A6546203D206E65772053797374656D2E44726177696E672E53697A65462839352E3538462C2031322E3546293B0D0A202020202020202020202020746869732E6C6162656C332E5374796C655072696F726974792E557365466F6E74203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C332E5374796C655072696F726974792E55736554657874416C69676E6D656E74203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C332E54657874203D20226C6162656C33223B0D0A2020202020202020202020202F2F200D0A2020202020202020202020202F2F206C6162656C320D0A2020202020202020202020202F2F200D0A202020202020202020202020746869732E6C6162656C322E4261636B436F6C6F72203D2053797374656D2E44726177696E672E436F6C6F722E4C69676874477261793B0D0A202020202020202020202020746869732E6C6162656C322E426F7264657273203D202828446576457870726573732E587472615072696E74696E672E426F726465725369646529282828446576457870726573732E587472615072696E74696E672E426F72646572536964652E4C656674207C20446576457870726573732E587472615072696E74696E672E426F72646572536964652E546F7029200D0A2020202020202020202020202020202020202020202020207C20446576457870726573732E587472615072696E74696E672E426F72646572536964652E426F74746F6D2929293B0D0A202020202020202020202020746869732E6C6162656C322E43616E47726F77203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C322E466F6E74203D206E65772053797374656D2E44726177696E672E466F6E742822417269616C222C2039462C2053797374656D2E44726177696E672E466F6E745374796C652E426F6C64293B0D0A202020202020202020202020746869732E6C6162656C322E4C6F636174696F6E466C6F6174203D206E657720446576457870726573732E5574696C732E506F696E74466C6F6174283138322E3735462C203046293B0D0A202020202020202020202020746869732E6C6162656C322E4E616D65203D20226C6162656C32223B0D0A202020202020202020202020746869732E6C6162656C322E50616464696E67203D206E657720446576457870726573732E587472615072696E74696E672E50616464696E67496E666F28322C20322C20302C20302C2031303046293B0D0A202020202020202020202020746869732E6C6162656C322E53697A6546203D206E65772053797374656D2E44726177696E672E53697A6546283635462C20333346293B0D0A202020202020202020202020746869732E6C6162656C322E5374796C655072696F726974792E5573654261636B436F6C6F72203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C322E5374796C655072696F726974792E557365426F7264657273203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C322E5374796C655072696F726974792E557365466F6E74203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C322E5374796C655072696F726974792E55736554657874416C69676E6D656E74203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C322E54657874203D202259544420416D6F756E74223B0D0A202020202020202020202020746869732E6C6162656C322E54657874416C69676E6D656E74203D20446576457870726573732E587472615072696E74696E672E54657874416C69676E6D656E742E426F74746F6D52696768743B0D0A2020202020202020202020202F2F200D0A2020202020202020202020202F2F206C6162656C310D0A2020202020202020202020202F2F200D0A202020202020202020202020746869732E6C6162656C312E4261636B436F6C6F72203D2053797374656D2E44726177696E672E436F6C6F722E4C69676874477261793B0D0A202020202020202020202020746869732E6C6162656C312E426F7264657273203D202828446576457870726573732E587472615072696E74696E672E426F7264657253696465292828446576457870726573732E587472615072696E74696E672E426F72646572536964652E546F70207C20446576457870726573732E587472615072696E74696E672E426F72646572536964652E426F74746F6D2929293B0D0A202020202020202020202020746869732E6C6162656C312E43616E47726F77203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C312E466F6E74203D206E65772053797374656D2E44726177696E672E466F6E742822417269616C222C2039462C2053797374656D2E44726177696E672E466F6E745374796C652E426F6C64293B0D0A202020202020202020202020746869732E6C6162656C312E4C6F636174696F6E466C6F6174203D206E657720446576457870726573732E5574696C732E506F696E74466C6F61742831462C203046293B0D0A202020202020202020202020746869732E6C6162656C312E4E616D65203D20226C6162656C31223B0D0A202020202020202020202020746869732E6C6162656C312E50616464696E67203D206E657720446576457870726573732E587472615072696E74696E672E50616464696E67496E666F28322C20322C20302C20302C2031303046293B0D0A202020202020202020202020746869732E6C6162656C312E53697A6546203D206E65772053797374656D2E44726177696E672E53697A6546283131312E3932462C20333346293B0D0A202020202020202020202020746869732E6C6162656C312E5374796C655072696F726974792E5573654261636B436F6C6F72203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C312E5374796C655072696F726974792E557365426F7264657273203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C312E5374796C655072696F726974792E557365466F6E74203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C312E5374796C655072696F726974792E55736554657874416C69676E6D656E74203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C312E54657874203D20224465736372697074696F6E223B0D0A202020202020202020202020746869732E6C6162656C312E54657874416C69676E6D656E74203D20446576457870726573732E587472615072696E74696E672E54657874416C69676E6D656E742E426F74746F6D4C6566743B0D0A2020202020202020202020202F2F200D0A2020202020202020202020202F2F206C6162656C31310D0A2020202020202020202020202F2F200D0A202020202020202020202020746869732E6C6162656C31312E4261636B436F6C6F72203D2053797374656D2E44726177696E672E436F6C6F722E4C69676874477261793B0D0A202020202020202020202020746869732E6C6162656C31312E426F7264657273203D202828446576457870726573732E587472615072696E74696E672E426F726465725369646529282828446576457870726573732E587472615072696E74696E672E426F72646572536964652E4C656674207C20446576457870726573732E587472615072696E74696E672E426F72646572536964652E546F7029200D0A2020202020202020202020202020202020202020202020207C20446576457870726573732E587472615072696E74696E672E426F72646572536964652E426F74746F6D2929293B0D0A202020202020202020202020746869732E6C6162656C31312E43616E47726F77203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C31312E466F6E74203D206E65772053797374656D2E44726177696E672E466F6E742822417269616C222C2039462C2053797374656D2E44726177696E672E466F6E745374796C652E426F6C64293B0D0A202020202020202020202020746869732E6C6162656C31312E4C6F636174696F6E466C6F6174203D206E657720446576457870726573732E5574696C732E506F696E74466C6F6174283131322E3932462C203046293B0D0A202020202020202020202020746869732E6C6162656C31312E4E616D65203D20226C6162656C3131223B0D0A202020202020202020202020746869732E6C6162656C31312E50616464696E67203D206E657720446576457870726573732E587472615072696E74696E672E50616464696E67496E666F28322C20322C20302C20302C2031303046293B0D0A202020202020202020202020746869732E6C6162656C31312E53697A6546203D206E65772053797374656D2E44726177696E672E53697A65462836392E3833462C20333346293B0D0A202020202020202020202020746869732E6C6162656C31312E5374796C655072696F726974792E5573654261636B436F6C6F72203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C31312E5374796C655072696F726974792E557365426F7264657273203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C31312E5374796C655072696F726974792E557365466F6E74203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C31312E5374796C655072696F726974792E55736554657874416C69676E6D656E74203D2066616C73653B0D0A202020202020202020202020746869732E6C6162656C31312E54657874203D202243757272656E7420416D6F756E74223B0D0A202020202020202020202020746869732E6C6162656C31312E54657874416C69676E6D656E74203D20446576457870726573732E587472615072696E74696E672E54657874416C69676E6D656E742E426F74746F6D52696768743B0D0A2020202020202020202020202F2F200D0A2020202020202020202020202F2F20587472615265706F72740D0A2020202020202020202020202F2F200D0A202020202020202020202020746869732E42616E64732E41646452616E6765286E657720446576457870726573732E587472615265706F7274732E55492E42616E645B5D207B0D0A202020202020202020202020202020202020202020202020746869732E746F704D617267696E42616E64312C0D0A202020202020202020202020202020202020202020202020746869732E64657461696C42616E64312C0D0A202020202020202020202020202020202020202020202020746869732E626F74746F6D4D617267696E42616E64312C0D0A202020202020202020202020202020202020202020202020746869732E5265706F72744865616465727D293B0D0A202020202020202020202020746869732E446174614D656D626572203D2022446174614669656C6473223B0D0A202020202020202020202020746869732E44617461536F75726365536368656D61203D207265736F75726365732E476574537472696E67282224746869732E44617461536F75726365536368656D6122293B0D0A202020202020202020202020746869732E446973706C61794E616D65203D2022506179636865636B2054617820537562205265706F7274223B0D0A202020202020202020202020746869732E4D617267696E73203D206E65772053797374656D2E44726177696E672E5072696E74696E672E4D617267696E7328302C203630322C20302C2030293B0D0A202020202020202020202020746869732E4E616D65203D2022587472615265706F7274223B0D0A202020202020202020202020746869732E50616765486569676874203D20313130303B0D0A202020202020202020202020746869732E506167655769647468203D203835303B0D0A202020202020202020202020746869732E56657273696F6E203D202231322E31223B0D0A202020202020202020202020282853797374656D2E436F6D706F6E656E744D6F64656C2E49537570706F7274496E697469616C697A6529287468697329292E456E64496E697428293B0D0A20202020202020207D0D0A202020207D0D0A7D0D0A, 
	[strName] = N'Paycheck Tax Sub Report', 
	[strGroup] = N'Sub Report', 
	[strBuilderServiceAddress] = N'', 
	[strWebViewerAddress] = N'', 
	[ysnAllowChangeFieldname] = 0, 
	[ysnAllowRemoveFieldname] = 0, 
	[ysnAllowAddFieldname] = 0, 
	[ysnAllowArchive] = 0, 
	[ysnUseAllAndOperator] = 0, 
	[ysnShowQuery] = 0, 
	[strDescription] = N'', 
	[intCompanyInformationId] = NULL, 
	[intGroupSort] = ISNULL(@intGroupSort, 1), 
	[intNameSort] = ISNULL(@intNameSort, 0) + 1, 
	[intConcurrencyId] = 1

SELECT @intReportId = SCOPE_IDENTITY()

-- Setup for the data source
INSERT [dbo].[tblRMDatasource] (
	[strName], 
	[intReportId], 
	[intConnectionId], 
	[strQuery], 
	[intDataSourceType], 
	[intConcurrencyId]
)
SELECT 
	[strName] = NULL, 
	[intReportId] = @intReportId, 
	[intConnectionId] = 1, 
	[strQuery] = N'SELECT * FROM vyuPRPaycheckTax', 
	[intDataSourceType] = 0, 
	[intConcurrencyId] = 1

PRINT('/*******************  BEGIN Deploy the sub report *******************/')
GO