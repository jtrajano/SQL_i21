GO
PRINT 'BEGIN CREATE fnTMGetContractPriceForCustomer'

GO
IF EXISTS (SELECT TOP 1 1 FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnTMGetContractPriceForCustomer]') AND type IN (N'FN'))
	DROP FUNCTION [dbo].[fnTMGetContractPriceForCustomer]
GO 

GO

IF EXISTS (SELECT TOP 1 * FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnTMGetContractForCustomer]') AND type IN (N'FN', N'TF'))
	DROP FUNCTION [dbo].[fnTMGetContractForCustomer]
GO 

IF (EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwcntmst'))
BEGIN 

	EXEC('
	
			CREATE FUNCTION [dbo].[fnTMGetContractForCustomer](
					@strCustomerNumber AS NVARCHAR(20)
					,@intSiteId INT
					,@intItemId INT
				)
				RETURNS @tblSpecialPriceTableReturn TABLE(
					strContractNumber NVARCHAR(20)
					,A4GLIdentity INT
					,ysnMaxPrice BIT
					,dblPrice NUMERIC(18,6)
				)
				AS
				BEGIN 

					DECLARE @returnValue NVARCHAR(20)
					DECLARE @strItemNo NVARCHAR(50)
					DECLARE @strItemClass NVARCHAR(50)
					--DECLARE @strLocationNo NVARCHAR(10)
					DECLARE @strClassFill NVARCHAR(20)

					DECLARE @strContractNumber NVARCHAR(50)
					DECLARE @A4GLIdentity INT
					DECLARE @ysnMaxPrice BIT
					DECLARE @dblPrice NUMERIC(18,6)
					DECLARE @ItemTable TMCompactItem
					DECLARE @ContractTable TMCompactContract


					---- get item info
					SELECT TOP 1 
						@strItemNo = vwitm_no COLLATE Latin1_General_CI_AS
						,@strItemClass = vwitm_class COLLATE Latin1_General_CI_AS
					FROM vwitmmst WHERE A4GLIdentity = @intItemId


					--- get site info
					SELECT TOP 1
						@strClassFill = strClassFillOption
					FROM tblTMSite WHERE intSiteID = @intSiteId


					--SELECT TOP 1
					--	@strLocationNo = vwloc_loc_no COLLATE Latin1_General_CI_AS
					--FROM tblTMSite A
					--INNER JOIN vwlocmst B
					--	ON A.intLocationId = B.A4GLIdentity
					--WHERE  A.intSiteID = @intSiteId

					---Item
					INSERT INTO @ItemTable(
						[intItemId] 
						,[strItemNo] 
						,[strLocation] 
					)
					SELECT
						[intItemId] = A4GLIdentity
						,[strItemNo] = vwitm_no COLLATE Latin1_General_CI_AS
						,[strLocation] = vwitm_loc_no COLLATE Latin1_General_CI_AS 
					FROM vwitmmst
					WHERE vwitm_avail_tm = ''Y''
						--AND vwitm_loc_no = @strLocationNo

					--- Contract
					INSERT INTO @ContractTable(
						[intContractId] 
						,[strContractNumber]
						,[strLocation]
						,[strItemOrClass]
						,[strCustomerNumber]
					)
					SELECT 
						[intContractId] = A4GLIdentity
						,[strContractNumber] = vwcnt_cnt_no
						,[strLocation] = vwcnt_loc_no
						,[strItemOrClass] = vwcnt_itm_or_cls
						,[strCustomerNumber] = vwcnt_cus_no
					FROM vwcntmst
					WHERE vwcnt_cus_no = @strCustomerNumber
						AND vwcnt_loc_no <> ''000''
						--AND vwcnt_loc_no = @strLocationNo
						AND vwcnt_due_rev_dt >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
						AND vwcnt_un_bal > 0
						AND A4GLIdentity NOT IN (SELECT DISTINCT intContractID 
												FROM tblTMSiteLink
												WHERE intSiteID <> @intSiteId
													AND intContractID NOT IN (SELECT DISTINCT intContractID
																			  FROM tblTMSiteLink
																			  WHERE intSiteID = @intSiteId))

					---------------------------------------------------------------------------------------------
					--Linked Site to Contract with Same Item and Contract Item is Available for TM
					---------------------------------------------------------------------------------------------
					SELECT TOP 1
						@strContractNumber = A.vwcnt_cnt_no
						,@A4GLIdentity = A.A4GLIdentity
						,@ysnMaxPrice = A.ysnMaxPrice
						,@dblPrice = A.vwcnt_un_prc
					FROM tblTMSiteLink C
					INNER JOIN vwcntmst A
						ON A.A4GLIdentity = C.intContractID
					INNER JOIN vwitmmst B
						ON A.vwcnt_itm_or_cls = B.vwitm_no
					INNER JOIN @ContractTable E
						ON A.A4GLIdentity = E.intContractId
					INNER JOIN tblTMSite G
						ON C.intSiteID = G.intSiteID
					INNER JOIN @ItemTable F
						ON G.intProduct =  F.intItemId
							AND B.A4GLIdentity = G.intProduct
					WHERE C.intSiteID = @intSiteId
		
					IF(@A4GLIdentity  IS NOT NULL)
					BEGIN
						GOTO INSERTANDRETURN
					END

					---------------------------------------------------------------------------------------------
					---------------------------------------------------------------------------------------------

					---------------------------------------------------------------------------------------------
					--Linked Site to Contract with Different Item and Contract Item is Available for TM
					---------------------------------------------------------------------------------------------

					SELECT TOP 1
						@strContractNumber = A.vwcnt_cnt_no
						,@A4GLIdentity = A.A4GLIdentity
						,@ysnMaxPrice = A.ysnMaxPrice
						,@dblPrice = A.vwcnt_un_prc
					FROM tblTMSiteLink C
					INNER JOIN vwcntmst A
						ON A.A4GLIdentity = C.intContractID
					INNER JOIN vwitmmst B
						ON A.vwcnt_itm_or_cls = B.vwitm_no
					INNER JOIN @ContractTable E
						ON A.A4GLIdentity = E.intContractId
					INNER JOIN @ItemTable F
						ON B.A4GLIdentity =  F.intItemId
					WHERE C.intSiteID = @intSiteId
		
					IF(@A4GLIdentity  IS NOT NULL)
					BEGIN
						GOTO INSERTANDRETURN
					END
					---------------------------------------------------------------------------------------------
					---------------------------------------------------------------------------------------------

					---------------------------------------------------------------------------------------------
					---Linked Site to Contract with No Item for Product Class that Matches Site Item Class
					---------------------------------------------------------------------------------------------

					SELECT TOP 1
						@strContractNumber = A.vwcnt_cnt_no
						,@A4GLIdentity = A.A4GLIdentity
						,@ysnMaxPrice = A.ysnMaxPrice
						,@dblPrice = A.vwcnt_un_prc
					FROM vwcntmst A
		
					INNER JOIN tblTMSiteLink C
						ON A.A4GLIdentity = C.intContractID
					INNER JOIN @ContractTable E
						ON A.A4GLIdentity = E.intContractId
					WHERE C.intSiteID = @intSiteId
						AND A.vwcnt_itm_or_cls COLLATE Latin1_General_CI_AS = @strItemClass
		
					IF(@A4GLIdentity  IS NOT NULL)
					BEGIN
						GOTO INSERTANDRETURN
					END
					---------------------------------------------------------------------------------------------
					---------------------------------------------------------------------------------------------

					---------------------------------------------------------------------------------------------
					---Contract with Same Item and Contract Item is Available for TM	
					---------------------------------------------------------------------------------------------

					SELECT TOP 1
						@strContractNumber = A.vwcnt_cnt_no
						,@A4GLIdentity = A.A4GLIdentity
						,@ysnMaxPrice = A.ysnMaxPrice
						,@dblPrice = A.vwcnt_un_prc
					FROM vwcntmst A
					INNER JOIN vwitmmst B
						ON A.vwcnt_itm_or_cls = B.vwitm_no
					INNER JOIN @ContractTable E
						ON A.A4GLIdentity = E.intContractId
					INNER JOIN @ItemTable F
						ON B.A4GLIdentity =  F.intItemId
					INNER JOIN tblTMSite G
						ON B.A4GLIdentity = G.intProduct
					WHERE G.intSiteID = @intSiteId
		
					IF(@A4GLIdentity  IS NOT NULL)
					BEGIN
						GOTO INSERTANDRETURN
					END
					---------------------------------------------------------------------------------------------
					---------------------------------------------------------------------------------------------


					---------------------------------------------------------------------------------------------
					---Contract with Different Item In Same Class and Site setup for Class Fill = Product Class and Contract Item is Available for TM
					---------------------------------------------------------------------------------------------
					IF(@strClassFill = ''Product Class'')
					BEGIN
						SELECT TOP 1
							@strContractNumber = A.vwcnt_cnt_no
							,@A4GLIdentity = A.A4GLIdentity
							,@ysnMaxPrice = A.ysnMaxPrice
							,@dblPrice = A.vwcnt_un_prc
						FROM vwcntmst A
						INNER JOIN vwitmmst B
							ON A.vwcnt_itm_or_cls = B.vwitm_no
						INNER JOIN @ContractTable E
							ON A.A4GLIdentity = E.intContractId
						INNER JOIN @ItemTable F
							ON B.A4GLIdentity =  F.intItemId
						WHERE B.vwitm_class COLLATE Latin1_General_CI_AS = @strItemClass
							AND LTRIM(vwcnt_itm_or_cls) <> ''''
		
						IF(@A4GLIdentity  IS NOT NULL)
						BEGIN
							GOTO INSERTANDRETURN
						END
					END
					---------------------------------------------------------------------------------------------
					---------------------------------------------------------------------------------------------

					---------------------------------------------------------------------------------------------
					---Contract with Different Item In Different Class and Site setup for Class Fill = Any Item and Contract Item is Available for TM
					---------------------------------------------------------------------------------------------
					IF(@strClassFill = ''Any Item'')
					BEGIN
						SELECT TOP 1
							@strContractNumber = A.vwcnt_cnt_no
							,@A4GLIdentity = A.A4GLIdentity
							,@ysnMaxPrice = A.ysnMaxPrice
							,@dblPrice = A.vwcnt_un_prc
						FROM vwcntmst A
						INNER JOIN @ContractTable E
							ON A.A4GLIdentity = E.intContractId
						
		
						IF(@A4GLIdentity  IS NOT NULL)
						BEGIN
							GOTO INSERTANDRETURN
						END
					END
					---------------------------------------------------------------------------------------------
					---------------------------------------------------------------------------------------------

					---------------------------------------------------------------------------------------------
					---Contract with No item, but for Product Class that Matches Site Item Class
					---------------------------------------------------------------------------------------------
					SELECT TOP 1
						@strContractNumber = A.vwcnt_cnt_no
						,@A4GLIdentity = A.A4GLIdentity
						,@ysnMaxPrice = A.ysnMaxPrice
						,@dblPrice = A.vwcnt_un_prc
					FROM vwcntmst A
					INNER JOIN vwitmmst B
						ON A.vwcnt_itm_or_cls = B.vwitm_class
					INNER JOIN @ContractTable E
						ON A.A4GLIdentity = E.intContractId
					INNER JOIN @ItemTable F
						ON B.A4GLIdentity =  F.intItemId
					WHERE A.vwcnt_itm_or_cls COLLATE Latin1_General_CI_AS = @strItemClass
		
					IF(@A4GLIdentity  IS NOT NULL)
					BEGIN
						GOTO INSERTANDRETURN
					END
					---------------------------------------------------------------------------------------------
					---------------------------------------------------------------------------------------------

					RETURN

					INSERTANDRETURN:
					INSERT INTO @tblSpecialPriceTableReturn(
						strContractNumber
						,A4GLIdentity
						,ysnMaxPrice
						,dblPrice
					)
					SELECT 
						@strContractNumber
						,@A4GLIdentity
						,@ysnMaxPrice
						,@dblPrice 
					RETURN
				END
	')
END
GO
PRINT 'END CREATE fnTMGetContractPriceForCustomer'

GO




/*

GO
PRINT 'BEGIN CREATE fnTMGetContractPriceForCustomer'

GO
IF EXISTS (SELECT TOP 1 1 FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnTMGetContractPriceForCustomer]') AND type IN (N'FN'))
	DROP FUNCTION [dbo].[fnTMGetContractPriceForCustomer]
GO 

GO

IF EXISTS (SELECT TOP 1 * FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnTMGetContractForCustomer]') AND type IN (N'FN', N'TF'))
	DROP FUNCTION [dbo].[fnTMGetContractForCustomer]
GO 

IF (EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwcntmst'))
BEGIN 

	EXEC('
	CREATE FUNCTION [dbo].[fnTMGetContractForCustomer](
		@strCustomerNumber AS NVARCHAR(20)
		,@intSiteId INT
	)
	RETURNS @tblSpecialPriceTableReturn TABLE(
		strContractNumber NVARCHAR(20)
		,A4GLIdentity INT
		,ysnMaxPrice BIT
		,dblPrice NUMERIC(18,6)
	)
	AS
	BEGIN 

		DECLARE @returnValue NVARCHAR(20)

		INSERT INTO @tblSpecialPriceTableReturn(
			strContractNumber
			,A4GLIdentity
			,ysnMaxPrice
			,dblPrice
		)
		SELECT TOP 1 
				vwcnt_cnt_no
				,A4GLIdentity
				,ysnMaxPrice
				,vwcnt_un_prc 
		FROM vwcntmst
		WHERE vwcnt_cus_no = @strCustomerNumber
			AND vwcnt_loc_no <> ''000''
			AND vwcnt_due_rev_dt >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
			AND vwcnt_un_bal > 0
			AND A4GLIdentity NOT IN (SELECT DISTINCT intContractID 
									FROM tblTMSiteLink
									WHERE intSiteID <> @intSiteId
										AND intContractID NOT IN (SELECT DISTINCT intContractID
																  FROM tblTMSiteLink
																  WHERE intSiteID = @intSiteId))
		RETURN
	END
	')
END
GO
PRINT 'END CREATE fnTMGetContractPriceForCustomer'

GO
*/