CREATE PROCEDURE [dbo].[uspSTstgInsertMixMatchFile]
	@strFilePrefix						NVARCHAR(50)
	, @intStoreId						INT
	, @intRegisterId					INT
	, @ysnClearRegisterPromotion		BIT
	, @dtmBeginningChangeDate			DATETIME
	, @dtmEndingChangeDate				DATETIME
	, @strGeneratedXML					NVARCHAR(MAX)	OUTPUT
	, @intImportFileHeaderId			INT				OUTPUT
	, @ysnSuccessResult					BIT				OUTPUT
	, @strMessageResult					NVARCHAR(1000)	OUTPUT
AS
BEGIN
	BEGIN TRY

		-- =========================================================================================================
		-- [START] - CREATE TRANSACTION
		-- =========================================================================================================
		DECLARE @InitTranCount INT;
		SET @InitTranCount = @@TRANCOUNT
		DECLARE @Savepoint NVARCHAR(150) = 'uspSTstgInsertMixMatchFile' + CAST(NEWID() AS NVARCHAR(100)); 

		IF @InitTranCount = 0
			BEGIN
				BEGIN TRANSACTION
			END		
		ELSE
			BEGIN
				SAVE TRANSACTION @Savepoint
			END
		-- =========================================================================================================
		-- [START] - CREATE TRANSACTION
		-- =========================================================================================================




		SET @ysnSuccessResult = CAST(1 AS BIT) -- Set to true
		SET @strMessageResult = ''
		
		DECLARE @xml XML = N''
		DECLARE @strXML AS NVARCHAR(MAX)
		DECLARE @strVersion NVARCHAR(50)

		-- DECLARE @strFilePrefix AS NVARCHAR(10) = 'MMT'

		DECLARE @strRegister NVARCHAR(200)
				, @strRegisterClass NVARCHAR(200)
				, @strXmlVersion NVARCHAR(10)

		SELECT @strRegister = strRegisterName 
				, @strRegisterClass = strRegisterClass
				, @strXmlVersion = strXmlVersion
		FROM dbo.tblSTRegister 
		WHERE intRegisterId = @intRegisterId


		-- =========================================================================================================
		-- Check if register has intImportFileHeaderId
		IF EXISTS(SELECT * FROM tblSTRegisterFileConfiguration WHERE intRegisterId = @intRegisterId AND strFilePrefix = @strFilePrefix)
			BEGIN
					SELECT TOP 1 @intImportFileHeaderId = intImportFileHeaderId 
					FROM tblSTRegisterFileConfiguration 
					WHERE intRegisterId = @intRegisterId 
					AND strFilePrefix = @strFilePrefix
			END
		ELSE
			BEGIN
					SET @ysnSuccessResult = CAST(0 AS BIT) -- Set to false
					SET @strGeneratedXML = ''
					SET @intImportFileHeaderId = 0
					SET @strMessageResult = 'Register ' + @strRegister + ' has no Outbound setup for Promotion Sales List - Mix and Match (' + @strFilePrefix + ')'

					RETURN
			END
		-- =========================================================================================================

		-- Create temp table @tblTempWeekDayAvailability
		BEGIN
			DECLARE @tblTempWeekDayAvailability TABLE 
			(
				[intPromoSalesListId]		INT,
				[PromotionID]				INT,
				[strAvailable]				NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
				[strWeekDay]				NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
				[intSort]					INT, 
				[strStartTime]				NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL,
				[strEndTime]				NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL
			)
		END




		IF(@strRegisterClass = 'PASSPORT')
			BEGIN
				---- Create Unique Identifier
				---- Handles multiple Update of registers by different Stores
				--DECLARE @strUniqueGuid AS NVARCHAR(50) = NEWID()

				---- Table and Condition
				--DECLARE @strTableAndCondition AS NVARCHAR(250) = 'tblSTstgPassportPricebookMixMatchMMT33~strUniqueGuid=''' + @strUniqueGuid + ''''

				IF(@strXmlVersion = '3.4')
					BEGIN
							-- OLD CODE
							BEGIN
								PRINT 'OLD'
								--INSERT INTO tblSTstgPassportPricebookMixMatchMMT33
							--(
							--	[StoreLocationID], 
							--	[VendorName], 
							--	[VendorModelVersion], 
							--	[TableActionType], 
							--	[RecordActionType], 
							--	[MMTDetailRecordActionType], 
							--	[PromotionID], 
							--	[PromotionReason], 
							--	[MixMatchDescription],
							--	[TransactionLimit],
							--	[ItemListID],
							--	[StartDate],
							--	[StartTime],
							--	[StopDate],
							--	[StopTime],
							--	[MixMatchUnits],
							--	[MixMatchPrice],
							--	[strUniqueGuid]
							--)
							--SELECT DISTINCT
							--	ST.intStoreNo AS [StoreLocationID]
							--	, 'iRely' AS [VendorName]  	
							--	, (SELECT TOP (1) strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC) AS [VendorModelVersion]
							--	, CASE
							--		WHEN @ysnClearRegisterPromotion = CAST(1 AS BIT) THEN 'initialize'
							--		WHEN @ysnClearRegisterPromotion = CAST(0 AS BIT) THEN 'update'
							--	END AS [TableActionType]
							--	, 'addchange' AS [RecordActionType] 
							--	, CASE PSL.ysnDeleteFromRegister 
							--		WHEN 0 
							--			THEN 'addchange' 
							--		WHEN 1 
							--			THEN 'delete' 
							--		ELSE 'addchange' 
							--	END AS [MMTDetailRecordActionType] 
							--	, PSL.intPromoSalesId AS [PromotionID]
							--	, PSL.strPromoReason AS [PromotionReason]
							--	, PSL.strPromoSalesDescription AS [MixMatchDescription]
							--	, 9999 AS [TransactionLimit]
							--	, PIL.intPromoItemListNo AS [ItemListID]
							--	, CONVERT(nvarchar(10), PSL.dtmPromoBegPeriod, 126) AS [StartDate]
							--	, CONVERT(varchar, CAST('0:00:00' AS TIME), 108) AS [StartTime]
							--	, CONVERT(nvarchar(10), PSL.dtmPromoEndPeriod, 126) AS [StopDate]
							--	, CONVERT(varchar, CAST('23:59:59' AS TIME), 108) AS [StopTime] 
							--	, PSL.intPromoUnits [MixMatchUnits]
							--	, PSL.dblPromoPrice [MixMatchPrice]
							--	, @strUniqueGuid AS [strUniqueGuid]
							--FROM tblSTPromotionSalesListDetail PSLD
							--INNER JOIN tblSTPromotionSalesList PSL
							--	ON PSLD.intPromoSalesListId = PSL.intPromoSalesListId
							--INNER JOIN tblSTPromotionItemList PIL 
							--	ON PSLD.intPromoItemListId = PIL.intPromoItemListId
							--INNER JOIN tblSTStore ST 
							--	ON PSL.intStoreId = ST.intStoreId
							--INNER JOIN tblSTRegister R 
							--	ON R.intRegisterId = ST.intRegisterId
							--INNER JOIN tblSMCompanyLocation CL 
							--	ON ST.intCompanyLocationId = CL.intCompanyLocationId
							--INNER JOIN tblICItemLocation IL
							--	ON CL.intCompanyLocationId = IL.intLocationId
							--	WHERE ST.intStoreId = @intStoreId
							--		AND PSL.strPromoType = 'M' -- <--- 'M' = Mix and Match

							--IF EXISTS(SELECT TOP 1 1 FROM tblSTstgPassportPricebookMixMatchMMT33 WHERE strUniqueGuid = @strUniqueGuid)
							--	BEGIN
							--		--Generate XML for the pricebook data availavle in staging table
							--		EXEC dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, @strTableAndCondition, 0, @strGeneratedXML OUTPUT

							--		--Once XML is generated delete the data from pricebook staging table.
							--		DELETE 
							--		FROM tblSTstgPassportPricebookMixMatchMMT33
							--		WHERE strUniqueGuid = @strUniqueGuid
							--	END
							--ELSE 
							--	BEGIN
							--		SET @ysnSuccessResult = CAST(0 AS BIT)
							--		SET @strMessageResult = 'No result found to generate Mix/Match - ' + @strFilePrefix + ' Outbound file'
							--	END
							END

							-- NEW
							BEGIN
								-- Create temp table @tblTempPassportMixMatch
								BEGIN
									DECLARE @tblTempPassportMixMatch TABLE 
									(
										[intPromoSalesId]			INT,
										[intPromoSalesListId]		INT,
										[intPromoSalesListDetailId]	INT,
										[StoreLocationID]			INT, 
										[VendorName]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
										[VendorModelVersion]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,  
										[TableActionType]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
										[RecordActionType]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,  
										[MMTDetailRecordActionType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
										[PromotionID]				INT, 
										[PromotionReason]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
										[MixMatchDescription]		NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
										[TransactionLimit]			INT,
										[ItemListId]				INT,
										[StartDate]					DATE,
										[StartTime]					TIME,
										[StopDate]					DATE,
										[StopTime]					TIME,
										[MixMatchUnits]				INT,
										[MixMatchPrice]				NUMERIC(18, 2)
									)
								END

								---- Create temp table @tblTempSapphireCommanderWeekDayAvailability
								--BEGIN
								--	DECLARE @tblTempSapphireCommanderWeekDayAvailability TABLE 
								--	(
								--		[intPromoSalesListId]		INT,
								--		[PromotionID]				INT,
								--		[strAvailable]				NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
								--		[strWeekDay]				NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
								--		[intSort]					INT, 
								--		[strStartTime]				NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL,
								--		[strEndTime]				NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL
								--	)
								--END



								-- INSERT TO @tblTempPassportMixMatch
								BEGIN
									INSERT INTO @tblTempPassportMixMatch
									(
										[intPromoSalesId],
										[intPromoSalesListId],
										[intPromoSalesListDetailId],
										[StoreLocationID], 
										[VendorName], 
										[VendorModelVersion],  
										[TableActionType], 
										[RecordActionType],  
										[MMTDetailRecordActionType], 
										[PromotionID], 
										[PromotionReason], 
										[MixMatchDescription], 
										[TransactionLimit],
										[ItemListId],
										[StartDate],
										[StartTime],
										[StopDate],
										[StopTime],
										[MixMatchUnits],
										[MixMatchPrice]
									)
									SELECT DISTINCT
										[intPromoSalesId]				= PSL.intPromoSalesId,
										[intPromoSalesListId]			= PSL.intPromoSalesListId,
										[intPromoSalesListDetailId]		= PSLD.intPromoSalesListDetailId,
										[StoreLocationID]				= ST.intStoreNo, 
										[VendorName]					= 'iRely', 
										[VendorModelVersion]			= (SELECT TOP (1) strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC),  
										[TableActionType]				= CASE
																			WHEN @ysnClearRegisterPromotion = CAST(1 AS BIT) THEN 'initialize'
																			WHEN @ysnClearRegisterPromotion = CAST(0 AS BIT) THEN 'update'
																		END, 
										[RecordActionType]				= 'addchange',  
										[MMTDetailRecordActionType]		= CASE PSL.ysnDeleteFromRegister 
																			WHEN 0 
																				THEN 'addchange' 
																			WHEN 1 
																				THEN 'delete' 
																			ELSE 'addchange' 
																		END, 
										[PromotionID]					= PSL.intPromoSalesId, 
										[PromotionReason]				= PSL.strPromoReason, 
										[MixMatchDescription]			= PSL.strPromoSalesDescription, 
										[TransactionLimit]				= 9999,
										[ItemListId]					= PIL.intPromoItemListNo,
										[StartDate]						= CONVERT(nvarchar(10), PSL.dtmPromoBegPeriod, 126),
										[StartTime]						= CONVERT(varchar, CAST('0:00:00' AS TIME), 108),
										[StopDate]						= CONVERT(nvarchar(10), PSL.dtmPromoEndPeriod, 126),
										[StopTime]						= CONVERT(varchar, CAST('23:59:59' AS TIME), 108),
										[MixMatchUnits]					= PSL.intPromoUnits,
										[MixMatchPrice]					= PSL.dblPromoPrice
									FROM tblSTPromotionSalesListDetail PSLD
									INNER JOIN tblSTPromotionSalesList PSL
										ON PSLD.intPromoSalesListId = PSL.intPromoSalesListId
									INNER JOIN tblSTPromotionItemList PIL 
										ON PSLD.intPromoItemListId = PIL.intPromoItemListId
									INNER JOIN tblSTStore ST 
										ON PSL.intStoreId = ST.intStoreId
									INNER JOIN tblSTRegister R 
										ON R.intRegisterId = ST.intRegisterId
									INNER JOIN tblSMCompanyLocation CL 
										ON ST.intCompanyLocationId = CL.intCompanyLocationId
									INNER JOIN tblICItemLocation IL
										ON CL.intCompanyLocationId = IL.intLocationId
									WHERE ST.intStoreId = @intStoreId
										AND PSL.strPromoType = 'M' 
										AND (
										       CAST(PSL.dtmPromoBegPeriod AS DATE) >= CAST(@dtmBeginningChangeDate AS DATE)
										       AND 
											   CAST(PSL.dtmPromoEndPeriod AS DATE)  <= CAST(@dtmEndingChangeDate AS DATE)
										       AND 
											   CAST(PSL.dtmPromoEndPeriod AS DATE)  >= GETDATE()
											) -- ST-1227
								END

								-- INSERT @tblTempWeekDayAvailability
								BEGIN
									INSERT INTO @tblTempWeekDayAvailability
									(
										[intPromoSalesListId],
										[PromotionID],
										[strAvailable],
										[strWeekDay], 
										[intSort], 
										[strStartTime],
										[strEndTime]
									)
									SELECT 
										[intPromoSalesListId]	= [Changes].intPromoSalesListId,
										[PromotionID]			= [Changes].intPromoSalesId,
										[strAvailable]			= [Changes].strAvailable,
										[strWeekDay]			= [Changes].strWeekDay, 
										[intSort]				= [Changes].intSort, 
										[strStartTime]			= [Changes].strStartTime,
										[strEndTime]			= [Changes].strEndTime
									FROM 
									(
										SELECT DISTINCT 
											intPromoSalesListId, 
											intPromoSalesId,
											strWeekDay = CASE	
															WHEN StartTime = 'strStartTimePromotionSunday'
																THEN 'Sunday'
															WHEN StartTime = 'strStartTimePromotionMonday'
																THEN 'Monday'
															WHEN StartTime = 'strStartTimePromotionTuesday'
																THEN 'Tuesday'
															WHEN StartTime = 'strStartTimePromotionWednesday'
																THEN 'Wednesday'
															WHEN StartTime = 'strStartTimePromotionThursday'
																THEN 'Thursday'
															WHEN StartTime = 'strStartTimePromotionFriday'
																THEN 'Friday'
															WHEN StartTime = 'strStartTimePromotionSaturday'
																THEN 'Saturday'
														END,
											intSort = CASE	
															WHEN StartTime = 'strStartTimePromotionSunday'
																THEN 1
															WHEN StartTime = 'strStartTimePromotionMonday'
																THEN 2
															WHEN StartTime = 'strStartTimePromotionTuesday'
																THEN 3
															WHEN StartTime = 'strStartTimePromotionWednesday'
																THEN 4
															WHEN StartTime = 'strStartTimePromotionThursday'
																THEN 5
															WHEN StartTime = 'strStartTimePromotionFriday'
																THEN 6
															WHEN StartTime = 'strStartTimePromotionSaturday'
																THEN 7
														END,
											strAvailable,
											strStartTime, 
											strEndTime
										FROM 
										(
											SELECT sl.intPromoSalesListId
													, sl.intPromoSalesId
													, strWeekDayPromotionSunday				= CASE WHEN sl.ysnWeekDayPromotionSunday = 1 THEN 'yes' ELSE 'no' END
													, strWeekDayPromotionMonday				= CASE WHEN sl.ysnWeekDayPromotionMonday = 1 THEN 'yes' ELSE 'no' END
													, strWeekDayPromotionTuesday			= CASE WHEN sl.ysnWeekDayPromotionTuesday = 1 THEN 'yes' ELSE 'no' END
													, strWeekDayPromotionWednesday			= CASE WHEN sl.ysnWeekDayPromotionWednesday = 1 THEN 'yes' ELSE 'no' END
													, strWeekDayPromotionThursday			= CASE WHEN sl.ysnWeekDayPromotionThursday = 1 THEN 'yes' ELSE 'no' END
													, strWeekDayPromotionFriday				= CASE WHEN sl.ysnWeekDayPromotionFriday = 1 THEN 'yes' ELSE 'no' END
													, strWeekDayPromotionSaturday			= CASE WHEN sl.ysnWeekDayPromotionSaturday = 1 THEN 'yes' ELSE 'no' END

													, strStartTimePromotionSunday			= CAST(ISNULL(sl.dtmStartTimePromotionSunday, '') AS NVARCHAR(8))
													, strStartTimePromotionMonday			= CAST(ISNULL(sl.dtmStartTimePromotionMonday, '') AS NVARCHAR(8))
													, strStartTimePromotionTuesday			= CAST(ISNULL(sl.dtmStartTimePromotionTuesday, '') AS NVARCHAR(8))
													, strStartTimePromotionWednesday		= CAST(ISNULL(sl.dtmStartTimePromotionWednesday, '') AS NVARCHAR(8))
													, strStartTimePromotionThursday			= CAST(ISNULL(sl.dtmStartTimePromotionThursday, '') AS NVARCHAR(8))
													, strStartTimePromotionFriday			= CAST(ISNULL(sl.dtmStartTimePromotionFriday, '') AS NVARCHAR(8))
													, strStartTimePromotionSaturday			= CAST(ISNULL(sl.dtmStartTimePromotionSaturday, '') AS NVARCHAR(8))
			
													, strEndTimePromotionSunday				= CAST(ISNULL(sl.dtmEndTimePromotionSunday, '') AS NVARCHAR(8))
													, strEndTimePromotionMonday				= CAST(ISNULL(sl.dtmEndTimePromotionMonday, '') AS NVARCHAR(8))
													, strEndTimePromotionTuesday			= CAST(ISNULL(sl.dtmEndTimePromotionTuesday, '') AS NVARCHAR(8))
													, strEndTimePromotionWednesday			= CAST(ISNULL(sl.dtmEndTimePromotionWednesday, '') AS NVARCHAR(8))
													, strEndTimePromotionThursday			= CAST(ISNULL(sl.dtmEndTimePromotionThursday, '') AS NVARCHAR(8))
													, strEndTimePromotionFriday				= CAST(ISNULL(sl.dtmEndTimePromotionFriday, '') AS NVARCHAR(8))
													, strEndTimePromotionSaturday			= CAST(ISNULL(sl.dtmEndTimePromotionSaturday, '') AS NVARCHAR(8))
											FROM tblSTPromotionSalesList sl
											INNER JOIN @tblTempPassportMixMatch temp
												ON sl.intPromoSalesId = temp.intPromoSalesId
										) t
										unpivot
										(
											strAvailable for Available in (strWeekDayPromotionSunday, strWeekDayPromotionMonday, strWeekDayPromotionTuesday, strWeekDayPromotionWednesday, strWeekDayPromotionThursday, strWeekDayPromotionFriday, strWeekDayPromotionSaturday)
										) a
										unpivot
										(
											strStartTime for StartTime in (strStartTimePromotionSunday, strStartTimePromotionMonday, strStartTimePromotionTuesday, strStartTimePromotionWednesday, strStartTimePromotionThursday, strStartTimePromotionFriday, strStartTimePromotionSaturday)
										) o
										unpivot
										(
											strEndTime for EndTime in (strEndTimePromotionSunday, strEndTimePromotionMonday, strEndTimePromotionTuesday, strEndTimePromotionWednesday, strEndTimePromotionThursday, strEndTimePromotionFriday, strEndTimePromotionSaturday)
										) n
										WHERE REPLACE(StartTime, 'strStartTimePromotion', '') = REPLACE(EndTime, 'strEndTimePromotion', '')	
											AND REPLACE(Available, 'strWeekDayPromotion', '') = REPLACE(StartTime, 'strStartTimePromotion', '')
									) [Changes]
								END


								IF EXISTS(SELECT TOP 1 1 FROM @tblTempPassportMixMatch)
									BEGIN
										--DECLARE @xml XML = N''

										SELECT @xml = 
										(
											SELECT
												trans.StoreLocationID		AS 'TransmissionHeader/StoreLocationID',
												trans.VendorName 			AS 'TransmissionHeader/VendorName',
												trans.VendorModelVersion 	AS 'TransmissionHeader/VendorModelVersion',
												(
													SELECT
													   MixMatchMaintenance.TableActionType			AS [TableAction/@type]
														,  MixMatchMaintenance.RecordActionType		AS [RecordAction/@type]
														, (
															SELECT
																MMTDetail.MMTDetailRecordActionType	AS [RecordAction/@type]
																, MMTDetail.PromotionID				AS [Promotion/PromotionID]
																, MMTDetail.PromotionReason			AS [Promotion/PromotionReason]		
																, MMTDetail.MixMatchDescription		AS [MixMatchDescription]
																, MMTDetail.TransactionLimit		AS [TransactionLimit]
																, MMTDetail.ItemListId				AS [ItemListId]
																, MMTDetail.StartDate				AS [StartDate]
																, MMTDetail.StartTime				AS [StartTime]
																, MMTDetail.StopDate				AS [StopDate]
																, MMTDetail.StopTime				AS [StopTime]

																, (
																	SELECT
																		--wda.strStartTime			AS [@startTime],
																		wda.strWeekDay				AS [@weekday],
																		wda.strAvailable			AS [@available]
																		--wda.strEndTime				AS [@stopTime]
																	FROM 
																	(
																		SELECT DISTINCT
																			wda.intSort
																			, wda.strAvailable
																			, wda.strStartTime
																			, wda.strEndTime
																			, wda.strWeekDay
																		FROM @tblTempWeekDayAvailability wda
																		WHERE wda.intPromoSalesListId = MMTDetail.intPromoSalesListId
																	) wda
																	ORDER BY wda.intSort ASC
																	FOR XML PATH('WeekdayAvailability'), TYPE

																)

																, MMTDetail.MixMatchUnits			AS [MixMatchEntry/MixMatchUnits]
																, MMTDetail.MixMatchPrice			AS [MixMatchEntry/MixMatchPrice]
															FROM
															(
																SELECT DISTINCT
																	mixDetail.intPromoSalesListId
																	, mixDetail.PromotionID
																	, mixDetail.MMTDetailRecordActionType
																	, mixDetail.PromotionReason
																	, mixDetail.MixMatchDescription
																	, mixDetail.TransactionLimit
																	, mixDetail.ItemListId
																	, mixDetail.StartDate
																	, mixDetail.StartTime
																	, mixDetail.StopDate
																	, mixDetail.StopTime
																	, mixDetail.MixMatchUnits
																	, mixDetail.MixMatchPrice
																FROM @tblTempPassportMixMatch mixDetail
																WHERE MixMatchMaintenance.PromotionID = mixDetail.PromotionID
															) MMTDetail
															FOR XML PATH('MMTDetail'), TYPE
														)
													FROM 
													(
														SELECT DISTINCT	
															PromotionID
															, TableActionType
															,  RecordActionType
															FROM @tblTempPassportMixMatch
														--ORDER BY PromotionID ASC
													) MixMatchMaintenance
													FOR XML PATH('MixMatchMaintenance'), TYPE
												)
											FROM 
											(
												SELECT DISTINCT
													StoreLocationID, 
													VendorName, 
													VendorModelVersion
												FROM @tblTempPassportMixMatch
											) trans
											FOR XML PATH('NAXML-MaintenanceRequest'), TYPE
										);

						
						
										SET @strVersion = N'3.4'
						
										-- INSERT Attributes 'page' and 'ofpages' to Root header
										SET @xml.modify('insert 
													   (
															attribute version { 
																					sql:variable("@strVersion")
																			  }		   
														) into (/*:NAXML-MaintenanceRequest)[1]');
						
										--SET @strXML = REPLACE(@strXML, '<NAXML-MaintenanceRequest', '<NAXML-MaintenanceRequest xmlns="http://www.naxml.org/POSBO/Vocabulary/2003-10-16"')
										-- SELECT @xml

										SET @strXML = CAST(@xml AS NVARCHAR(MAX))
										SET @strGeneratedXML = REPLACE(@strXML, '><', '>' + CHAR(13) + '<')

										--EXEC CopierDB.dbo.LongPrint @strGeneratedXML
									END
								ELSE
									BEGIN

										SET @strGeneratedXML		= ''
										SET @intImportFileHeaderId	= 0
										SET @ysnSuccessResult		= CAST(0 AS BIT)
										SET @strMessageResult		= 'No result found to generate MixMatch - ' + @strFilePrefix + ' Outbound file'

										GOTO ExitWithRollback
									END
							END
							
					END
			END
		ELSE IF(@strRegisterClass = 'RADIANT')
			BEGIN
				INSERT INTO tblSTstgMixMatchFile
				SELECT DISTINCT
				  ST.intStoreNo [StoreLocationID]
					, 'iRely' [VendorName]  	
					, 'Rel. 13.2.0' [VendorModelVersion]
					, 'update' [TableActionType]
					, 'addchange' [RecordActionType] 
					, CASE PSL.ysnDeleteFromRegister 
						WHEN 0 
							THEN 'addchange' 
						WHEN 1 
							THEN 'delete' 
						ELSE 'addchange' 
					END AS [MMTDetailRecordActionType] 
					, 'no' [MMTDetailRecordActionConfirm]
					, PSL.intPromoSalesId [PromotionID]
					, PSL.strPromoReason [PromotionReason]
					, PSL.strPromoSalesDescription [MixMatchDescription]
					, 1 [SalesRestrictCode]
					, CASE 
						WHEN PSL.ysnPurchaseAtleastMin = 1 
							THEN 'yes' 
						ELSE 'no' 
					END [MixMatchStrictHighFlagValue]
					, CASE 
						WHEN PSL.ysnPurchaseExactMultiples = 1 
							THEN 'yes' 
						ELSE 'no' 
					END [MixMatchStrictLowFlagValue]
					, PIL.intPromoItemListNo [ItemListID]
					, PSLD.intQuantity [MixMatchUnits]
					, PSLD.dblPrice [MixMatchPrice]
					, 'USD' [MixMatchPriceCurrency]	
					, CONVERT(nvarchar(10), PSL.dtmPromoBegPeriod, 126) [StartDate]
					, '0:00:01' [StartTime]
					, CONVERT(nvarchar(10), PSL.dtmPromoEndPeriod, 126) [StopDate]
					, '23:59:59' [StopTime]
					, CASE 
						WHEN R.strRegisterClass = 'RADIANT' 
							THEN 0 
						ELSE NULL 
					END [Priority]
					, 'yes' [WeekdayAvailabilitySunday]
					, 'Sunday' [WeekdaySunday]
					, 'yes' [WeekdayAvailabilityMonday]
					, 'Monday' [WeekdayMonday]
					, 'yes' [WeekdayAvailabilityTuesday]
					, 'Tuesday' [WeekdayTuesday]
					, 'yes' [WeekdayAvailabilityWednesday]
					, 'Wednesday' [WeekdayWednesday]
					, 'yes' [WeekdayAvailabilityThursday]
					, 'Thursday' [WeekdayThursday]
					, 'yes' [WeekdayAvailabilityFriday]
					, 'Friday' [WeekdayFriday]
					, 'yes' [WeekdayAvailabilitySaturday]
					, 'Saturday' [WeekdaySaturday]	
					, NULL [MixMatchPromotions]
					, R.strRegisterStoreId [DiscountExternalID]
				FROM tblICItem I
				JOIN tblICItemLocation IL 
					ON IL.intItemId = I.intItemId
				JOIN tblSMCompanyLocation L 
					ON L.intCompanyLocationId = IL.intLocationId
				JOIN tblICItemUOM IUOM 
					ON IUOM.intItemId = I.intItemId 
				JOIN tblICUnitMeasure IUM 
					ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
				JOIN tblSTStore ST 
					ON ST.intCompanyLocationId = L.intCompanyLocationId 
				JOIN tblSTRegister R 
					ON R.intStoreId = ST.intStoreId
				JOIN tblSTPromotionItemList PIL 
					ON PIL.intStoreId = ST.intStoreId
				JOIN tblSTPromotionSalesList PSL 
					ON PSL.intStoreId = ST.intStoreId --AND Cat.intCategoryId = PSL.intCategoryId
				JOIN tblSTPromotionSalesListDetail PSLD 
					ON PSLD.intPromoSalesListId = PSL.intPromoSalesListId
				WHERE R.intRegisterId = @intRegisterId 
					AND ST.intStoreId = @intStoreId 
					AND PSL.strPromoType = 'M' -- <--- 'M' = Mix and Match
					-- AND PSL.intPromoSalesId BETWEEN @BeginningMixMatchId AND @EndingMixMatchId
					AND (
							CAST(@dtmBeginningChangeDate AS DATE) >= CAST(PSL.dtmPromoBegPeriod AS DATE)
							 AND 
							CAST(@dtmEndingChangeDate AS DATE) <= CAST(PSL.dtmPromoEndPeriod AS DATE) 
							AND 
							CAST(PSL.dtmPromoEndPeriod AS DATE)  >= GETDATE()
						) -- ST-1227
				


				IF EXISTS(SELECT StoreLocationID FROM tblSTstgMixMatchFile)
					BEGIN
							-- Generate XML for the pricebook data availavle in staging table
							EXEC dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, 'tblSTstgMixMatchFile~intMixMatchFile > 0', 0, @strGeneratedXML OUTPUT

							-- Once XML is generated delete the data from pricebook  staging table.
							DELETE FROM tblSTstgMixMatchFile
					END
				ELSE 
					BEGIN
							SET @ysnSuccessResult = CAST(0 AS BIT)
							SET @strMessageResult = 'No result found to generate Mix/Match - ' + @strFilePrefix + ' Outbound file'
					END
			END
		ELSE IF(@strRegisterClass = 'SAPPHIRE/COMMANDER')
			BEGIN
				
				-- Create temp table @tblTempSapphireCommanderMixMatch
				BEGIN
					DECLARE @tblTempSapphireCommanderMixMatch TABLE 
					(
						[intPrimaryId] INT,
						[strStoreNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
						[strVendorName] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL, 
						[strVendorModelVersion] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,

						[strRecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 

						-- TOP 1 Promotion Item List Id
						[strPromotionID] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,			
						[strMixMatchDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,

						[strMixMatchStrictHighFlag] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
						[strMixMatchStrictLowFlag] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
						[strItemListID] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,

						[strStartDate] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
						[strStartTime] NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL,
						[strStopDate] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
						[strStopTime] NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL,

						-- TOP 1 from Promotion Item List Id
						[strMixMatchUnits] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,			
						[strMixMatchPrice] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
						[strPriority] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL
					)
				END

				---- Create temp table @tblTempSapphireCommanderWeekDayAvailability
				--BEGIN
				--	DECLARE @tblTempSapphireCommanderWeekDayAvailability TABLE 
				--	(
				--		[intPromoSalesListId]		INT,
				--		[strAvailable]				NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
				--		[strWeekDay]				NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
				--		[intSort]					INT, 
				--		[strStartTime]				NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL,
				--		[strEndTime]				NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL
				--	)
				--END
				



				-- Insert to temp table @tblTempSapphireCommanderMixMatch
				BEGIN
					INSERT INTO @tblTempSapphireCommanderMixMatch
					SELECT
						[intPrimaryId]						=	CAST(SalesList.intPromoSalesListId AS NVARCHAR(50)), 
						[strStoreNo]						=	CAST(SalesList.intStoreNo AS NVARCHAR(50)), 
						[strVendorName]						=	'iRely', 
						[strVendorModelVersion]				=	(SELECT TOP (1) strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC),

						[strRecordActionType]				=	CASE
																	WHEN (SalesList.ysnDeleteFromRegister = 1)
																		THEN 'delete'
																	ELSE 'addchange'
																END, 

						-- TOP 1 Promotion Item List Id
						[strPromotionID]					=	CAST(SalesList.intPromoSalesId AS NVARCHAR(50)),			
						[strMixMatchDescription]			=	SalesList.strPromoSalesDescription,

						[strMixMatchStrictHighFlag]			=	'yes',
						[strMixMatchStrictLowFlag]			=	'yes',
						[strItemListID]						=	CAST(PIL.intPromoItemListNo AS NVARCHAR(50)),

						[strStartDate]						=	CAST(CONVERT(DATE, SalesList.dtmPromoBegPeriod) AS NVARCHAR(10)),
						[strStartTime]						=	CAST(CONVERT(TIME, SalesList.dtmPromoBegPeriod) AS NVARCHAR(8)),
						[strStopDate]						=	CAST(CONVERT(DATE, SalesList.dtmPromoEndPeriod) AS NVARCHAR(10)),
						[strStopTime]						=	CAST(CONVERT(TIME, SalesList.dtmPromoEndPeriod) AS NVARCHAR(8)),

						-- TOP 1 from Promotion Item List Id
						[strMixMatchUnits]					=	CAST(SalesList.intQuantity AS NVARCHAR(50)),			
						[strMixMatchPrice]					=	CAST(CAST(SalesList.dblPrice AS DECIMAL(18,4)) AS NVARCHAR(50)),
						[strPriority]						=	NULL
					FROM
					(   
						SELECT ST.intStoreNo
							 , PSL.ysnDeleteFromRegister
							 , PSL.intPromoSalesId
							 , PSL.strPromoSalesDescription
							 , PSL.dtmPromoBegPeriod
							 , PSL.dtmPromoEndPeriod
							 , PSLD.* 
							 , ROW_NUMBER() OVER (PARTITION BY PSLD.intPromoSalesListId ORDER BY PSLD.intPromoSalesListId DESC) AS rn
						FROM tblSTPromotionSalesList PSL
						JOIN tblSTPromotionSalesListDetail PSLD
							ON PSL.intPromoSalesListId = PSLD.intPromoSalesListId
						JOIN tblSTStore ST
							ON PSL.intStoreId = ST.intStoreId 
						WHERE ST.intStoreId = @intStoreId
							AND PSL.strPromoType = 'M'
							AND (PSLD.intQuantity IS NOT NULL AND PSLD.intQuantity != 0)
							AND (PSLD.dblPrice IS NOT NULL AND PSLD.dblPrice != 0)
							AND (
									CAST(@dtmBeginningChangeDate AS DATE) >= CAST(PSL.dtmPromoBegPeriod AS DATE)
									 AND 
									CAST(@dtmEndingChangeDate AS DATE) <= CAST(PSL.dtmPromoEndPeriod AS DATE) 
									AND 
									CAST(PSL.dtmPromoEndPeriod AS DATE)  >= GETDATE()
								) -- ST-1227
						--ORDER BY PSLD.intPromoSalesListDetailId ASC
					) SalesList 
					JOIN tblSTPromotionItemList PIL
						ON SalesList.intPromoItemListId = PIL.intPromoItemListId
					WHERE SalesList.rn = 1	-- Only get Top 1 record from PSLD on every PSL
				END

				-- INSERT @tblTempSapphireCommanderWeekDayAvailability
				BEGIN
					INSERT INTO @tblTempWeekDayAvailability
					(
						[intPromoSalesListId],
						[strAvailable],
						[strWeekDay], 
						[intSort], 
						[strStartTime],
						[strEndTime]
					)
					SELECT 
						[intPromoSalesListId]	= [Changes].intPromoSalesListId,
						[strAvailable]			= [Changes].strAvailable,
						[strWeekDay]			= [Changes].strWeekDay, 
						[intSort]				= [Changes].intSort, 
						[strStartTime]			= [Changes].strStartTime,
						[strEndTime]			= [Changes].strEndTime
					FROM 
					(
						SELECT DISTINCT 
							intPromoSalesListId, 
							strWeekDay = CASE	
											WHEN StartTime = 'strStartTimePromotionSunday'
												THEN 'Sunday'
											WHEN StartTime = 'strStartTimePromotionMonday'
												THEN 'Monday'
											WHEN StartTime = 'strStartTimePromotionTuesday'
												THEN 'Tuesday'
											WHEN StartTime = 'strStartTimePromotionWednesday'
												THEN 'Wednesday'
											WHEN StartTime = 'strStartTimePromotionThursday'
												THEN 'Thursday'
											WHEN StartTime = 'strStartTimePromotionFriday'
												THEN 'Friday'
											WHEN StartTime = 'strStartTimePromotionSaturday'
												THEN 'Saturday'
										END,
							intSort = CASE	
											WHEN StartTime = 'strStartTimePromotionSunday'
												THEN 1
											WHEN StartTime = 'strStartTimePromotionMonday'
												THEN 2
											WHEN StartTime = 'strStartTimePromotionTuesday'
												THEN 3
											WHEN StartTime = 'strStartTimePromotionWednesday'
												THEN 4
											WHEN StartTime = 'strStartTimePromotionThursday'
												THEN 5
											WHEN StartTime = 'strStartTimePromotionFriday'
												THEN 6
											WHEN StartTime = 'strStartTimePromotionSaturday'
												THEN 7
										END,
							strAvailable,
							strStartTime, 
							strEndTime
						FROM 
						(
							SELECT sl.intPromoSalesListId
									, strWeekDayPromotionSunday				= CASE WHEN sl.ysnWeekDayPromotionSunday = 1 THEN 'yes' ELSE 'no' END
									, strWeekDayPromotionMonday				= CASE WHEN sl.ysnWeekDayPromotionMonday = 1 THEN 'yes' ELSE 'no' END
									, strWeekDayPromotionTuesday			= CASE WHEN sl.ysnWeekDayPromotionTuesday = 1 THEN 'yes' ELSE 'no' END
									, strWeekDayPromotionWednesday			= CASE WHEN sl.ysnWeekDayPromotionWednesday = 1 THEN 'yes' ELSE 'no' END
									, strWeekDayPromotionThursday			= CASE WHEN sl.ysnWeekDayPromotionThursday = 1 THEN 'yes' ELSE 'no' END
									, strWeekDayPromotionFriday				= CASE WHEN sl.ysnWeekDayPromotionFriday = 1 THEN 'yes' ELSE 'no' END
									, strWeekDayPromotionSaturday			= CASE WHEN sl.ysnWeekDayPromotionSaturday = 1 THEN 'yes' ELSE 'no' END

									, strStartTimePromotionSunday			= CAST(ISNULL(sl.dtmStartTimePromotionSunday, '') AS NVARCHAR(8))
									, strStartTimePromotionMonday			= CAST(ISNULL(sl.dtmStartTimePromotionMonday, '') AS NVARCHAR(8))
									, strStartTimePromotionTuesday			= CAST(ISNULL(sl.dtmStartTimePromotionTuesday, '') AS NVARCHAR(8))
									, strStartTimePromotionWednesday		= CAST(ISNULL(sl.dtmStartTimePromotionWednesday, '') AS NVARCHAR(8))
									, strStartTimePromotionThursday			= CAST(ISNULL(sl.dtmStartTimePromotionThursday, '') AS NVARCHAR(8))
									, strStartTimePromotionFriday			= CAST(ISNULL(sl.dtmStartTimePromotionFriday, '') AS NVARCHAR(8))
									, strStartTimePromotionSaturday			= CAST(ISNULL(sl.dtmStartTimePromotionSaturday, '') AS NVARCHAR(8))
			
									, strEndTimePromotionSunday				= CAST(ISNULL(sl.dtmEndTimePromotionSunday, '') AS NVARCHAR(8))
									, strEndTimePromotionMonday				= CAST(ISNULL(sl.dtmEndTimePromotionMonday, '') AS NVARCHAR(8))
									, strEndTimePromotionTuesday			= CAST(ISNULL(sl.dtmEndTimePromotionTuesday, '') AS NVARCHAR(8))
									, strEndTimePromotionWednesday			= CAST(ISNULL(sl.dtmEndTimePromotionWednesday, '') AS NVARCHAR(8))
									, strEndTimePromotionThursday			= CAST(ISNULL(sl.dtmEndTimePromotionThursday, '') AS NVARCHAR(8))
									, strEndTimePromotionFriday				= CAST(ISNULL(sl.dtmEndTimePromotionFriday, '') AS NVARCHAR(8))
									, strEndTimePromotionSaturday			= CAST(ISNULL(sl.dtmEndTimePromotionSaturday, '') AS NVARCHAR(8))
							FROM tblSTPromotionSalesList sl
							LEFT JOIN @tblTempSapphireCommanderMixMatch temp
								ON sl.intPromoSalesId = temp.intPrimaryId
						) t
						unpivot
						(
							strAvailable for Available in (strWeekDayPromotionSunday, strWeekDayPromotionMonday, strWeekDayPromotionTuesday, strWeekDayPromotionWednesday, strWeekDayPromotionThursday, strWeekDayPromotionFriday, strWeekDayPromotionSaturday)
						) a
						unpivot
						(
							strStartTime for StartTime in (strStartTimePromotionSunday, strStartTimePromotionMonday, strStartTimePromotionTuesday, strStartTimePromotionWednesday, strStartTimePromotionThursday, strStartTimePromotionFriday, strStartTimePromotionSaturday)
						) o
						unpivot
						(
							strEndTime for EndTime in (strEndTimePromotionSunday, strEndTimePromotionMonday, strEndTimePromotionTuesday, strEndTimePromotionWednesday, strEndTimePromotionThursday, strEndTimePromotionFriday, strEndTimePromotionSaturday)
						) n
						WHERE REPLACE(StartTime, 'strStartTimePromotion', '') = REPLACE(EndTime, 'strEndTimePromotion', '')	
							AND REPLACE(Available, 'strWeekDayPromotion', '') = REPLACE(StartTime, 'strStartTimePromotion', '')
					) [Changes]
				END



				IF EXISTS(SELECT TOP 1 1 FROM @tblTempSapphireCommanderMixMatch)
					BEGIN
						--DECLARE @xml XML = N''
				
						SELECT @xml =
						(
							SELECT
								trans.strStoreNo				AS 'TransmissionHeader/StoreLocationID',
								trans.strVendorName 			AS 'TransmissionHeader/VendorName',
								trans.strVendorModelVersion 	AS 'TransmissionHeader/VendorModelVersion',
								(
									SELECT
										'update' AS [TableAction/@type],
										'addchange' AS [RecordAction/@type],
										(
											SELECT 
												MixMatch.strRecordActionType		AS [RecordAction/@type],
												MixMatch.strPromotionID				AS [Promotion/PromotionID],
												MixMatch.strMixMatchDescription		AS [MixMatchDescription],
												MixMatch.strMixMatchStrictHighFlag	AS [MixMatchStrictHighFlag/@value],
												MixMatch.strMixMatchStrictLowFlag	AS [MixMatchStrictLowFlag/@value],
												MixMatch.strItemListID				AS [ItemListID],
												MixMatch.strStartDate				AS [StartDate],
												MixMatch.strStartTime				AS [StartTime],
												MixMatch.strStopDate				AS [StopDate],
												MixMatch.strStopTime				AS [StopTime],

												(
													SELECT 
														wda.strStartTime			AS [@startTime],
														wda.strAvailable			AS [@available],
														wda.strWeekDay				AS [@weekday],
														wda.strEndTime				AS [@stopTime]
													FROM 
													(
														SELECT DISTINCT
															wda.intSort
															, wda.strAvailable
															, wda.strStartTime
															, wda.strEndTime
															, wda.strWeekDay
														FROM @tblTempWeekDayAvailability wda
														WHERE wda.intPromoSalesListId = MixMatch.intPrimaryId
													) wda
													ORDER BY wda.intSort ASC
													FOR XML PATH('WeekdayAvailability'), TYPE
												),

												MixMatch.strMixMatchUnits			AS [MixMatchEntry/MixMatchUnits],
												MixMatch.strMixMatchPrice			AS [MixMatchEntry/MixMatchPrice],
												(select MixMatch.strPriority for xml path('Priority'), type)
												--MixMatch.strPriority				AS [Priority]
											FROM 
											(
												SELECT DISTINCT
													intPrimaryId
													, strPromotionID
													, strRecordActionType
													, strMixMatchDescription
													, strMixMatchStrictHighFlag
													, strMixMatchStrictLowFlag
													, strItemListID
													, strStartDate
													, strStartTime
													, strStopDate
													, strStopTime
													, strMixMatchUnits
													, strMixMatchPrice
													, strPriority
												FROM @tblTempSapphireCommanderMixMatch
											) MixMatch
											ORDER BY MixMatch.strPromotionID ASC
											FOR XML PATH('MMTDetail'), TYPE --elements xsinil
										)
									FOR XML PATH('MixMatchMaintenance'), TYPE	
								)
							FROM 
							(
								SELECT DISTINCT
									[strStoreNo], 
									[strVendorName], 
									[strVendorModelVersion]
								FROM @tblTempSapphireCommanderMixMatch
							) trans
							FOR XML PATH('NAXML-MaintenanceRequest'), TYPE
						);



						DECLARE @strXmlns AS NVARCHAR(50) = 'http://www.naxml.org/POSBO/Vocabulary/2003-10-16'
								
						SET @strVersion = N'3.4'

						-- INSERT Attributes 'page' and 'ofpages' to Root header
						SET @xml.modify('insert 
									   (
											attribute version { 
																	sql:variable("@strVersion")
															  }		   
										) into (/*:NAXML-MaintenanceRequest)[1]');

						SET @strXML = CAST(@xml AS NVARCHAR(MAX))
						SET @strXML = REPLACE(@strXML, '<NAXML-MaintenanceRequest', '<NAXML-MaintenanceRequest xmlns="http://www.naxml.org/POSBO/Vocabulary/2003-10-16"')
						
						SET @strGeneratedXML = REPLACE(@strXML, '><', '>' + CHAR(13) + '<')
					END
				ELSE 
					BEGIN
						SET @strGeneratedXML		= ''
						SET @intImportFileHeaderId	= 0
						SET @ysnSuccessResult		= CAST(0 AS BIT)
						SET @strMessageResult		= 'No result found to generate MixMatch - ' + @strFilePrefix + ' Outbound file'

						GOTO ExitWithRollback

					END
			END

	END TRY

	BEGIN CATCH
		SET @strGeneratedXML		= ''
		SET @intImportFileHeaderId	= 0
		SET @ysnSuccessResult = CAST(0 AS BIT)
		SET @strMessageResult = ERROR_MESSAGE()

		GOTO ExitWithRollback
	END CATCH
END





ExitWithCommit:
	IF @InitTranCount = 0
		BEGIN
			COMMIT TRANSACTION
		END

	GOTO ExitPost
	





ExitWithRollback:
		SET @ysnSuccessResult			= CAST(0 AS BIT)

		IF @InitTranCount = 0
			BEGIN
				IF ((XACT_STATE()) <> 0)
				BEGIN
					SET @strMessageResult = @strMessageResult + ' Will Rollback Transaction.'

					ROLLBACK TRANSACTION
				END
			END
			
		ELSE
			BEGIN
				IF ((XACT_STATE()) <> 0)
					BEGIN
						SET @strMessageResult = @strMessageResult + ' Will Rollback to Save point.'

						ROLLBACK TRANSACTION @Savepoint
					END
			END
			
				
		
		
	

		
ExitPost:


