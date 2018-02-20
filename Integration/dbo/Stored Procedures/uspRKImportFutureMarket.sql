IF EXISTS(select top 1 1 from sys.procedures where name = 'uspRKImportFutureMarket')
	DROP PROCEDURE uspRKImportFutureMarket
GO
CREATE PROCEDURE uspRKImportFutureMarket
	@Checking BIT = 0,
	@Total INT = 0 OUTPUT
	AS
BEGIN

		IF @Checking = 1
		BEGIN 
			SELECT @Total = COUNT (*) WHERE NOT EXISTS (SELECT strFutMarketName FROM tblRKFutureMarket WHERE strFutMarketName = 'CBOT') 
			SELECT @Total = @Total + COUNT (*) WHERE NOT EXISTS (SELECT strFutMarketName FROM tblRKFutureMarket WHERE strFutMarketName = 'KCBT') 
			SELECT @Total = @Total + COUNT (*) WHERE NOT EXISTS (SELECT strFutMarketName FROM tblRKFutureMarket WHERE strFutMarketName = 'MGEX')
			SELECT @Total = @Total + COUNT (*) WHERE NOT EXISTS (SELECT strFutMarketName FROM tblRKFutureMarket WHERE strFutMarketName = 'WINNIPEG')
			SELECT @Total = @Total + COUNT (*) WHERE NOT EXISTS (SELECT strFutMarketName FROM tblRKFutureMarket WHERE strFutMarketName = 'NEW YORK')

			RETURN
		END

		--IMPORT ORIGIN FUTURE MARKET
		INSERT INTO tblRKFutureMarket  
					(intConcurrencyId
					,strFutMarketName
					,strFutSymbol
					,intFutMonthsToOpen
					,dblContractSize
					,intUnitMeasureId
					,intCurrencyId)
		SELECT 1,'CBOT','C',5,5000,(SELECT intUnitMeasureId from tblICUnitMeasure WHERE strSymbol = 'BU'),3
		WHERE NOT EXISTS (SELECT strFutMarketName FROM tblRKFutureMarket WHERE strFutMarketName = 'CBOT') UNION ALL
		SELECT 1,'KCBT','K',5,5000,(SELECT intUnitMeasureId from tblICUnitMeasure WHERE strSymbol = 'BU'),3 
		WHERE NOT EXISTS (SELECT strFutMarketName FROM tblRKFutureMarket WHERE strFutMarketName = 'KCBT') UNION ALL
		SELECT 1,'MGEX','M',5,5000,(SELECT intUnitMeasureId from tblICUnitMeasure WHERE strSymbol = 'BU'),3 
		WHERE NOT EXISTS (SELECT strFutMarketName FROM tblRKFutureMarket WHERE strFutMarketName = 'MGEX') UNION ALL
		SELECT 1,'WINNIPEG','W',5,5000,(SELECT intUnitMeasureId from tblICUnitMeasure WHERE strSymbol = 'BU'),3 
		WHERE NOT EXISTS (SELECT strFutMarketName FROM tblRKFutureMarket WHERE strFutMarketName = 'WINNIPEG') UNION ALL
		SELECT 1,'NEW YORK','N',5,5000,(SELECT intUnitMeasureId from tblICUnitMeasure WHERE strSymbol = 'BU'),3
		WHERE NOT EXISTS (SELECT strFutMarketName FROM tblRKFutureMarket WHERE strFutMarketName = 'NEW YORK') 

		--IMPORT ORIGIN FUTURE MONTHS
		INSERT INTO tblRKFuturesMonth 
				(intConcurrencyId
				,strFutureMonth
				,intFutureMarketId
				,strSymbol
				,intYear
				,dtmSpotDate
				,ysnExpired) 
		select distinct 1,
				 SUBSTRING(gacnt_bot_option,1,3)+' '+SUBSTRING(gacnt_bot_option,4,2)
				,FM.intFutureMarketId
				,CASE SUBSTRING(gacnt_bot_option,1,3) 
					  WHEN 'JAN' THEN 'F'
					  WHEN 'FEB' THEN 'G'
					  WHEN 'MAR' THEN 'H'
					  WHEN 'APR' THEN 'J'
					  WHEN 'MAY' THEN 'K'
					  WHEN 'JUN' THEN 'M'
					  WHEN 'JUL' THEN 'N'
					  WHEN 'AUG' THEN 'Q'
					  WHEN 'SEP' THEN 'U'
					  WHEN 'OCT' THEN 'V'
					  WHEN 'NOV' THEN 'X'
					  WHEN 'DEC' THEN 'Z'
					  END
				,SUBSTRING(gacnt_bot_option,4,2)
				,GETDATE()
				,0
				--,gacnt_com_cd 
		FROM gacntmst CN
		JOIN gacommst CM ON CM.gacom_com_cd = CN.gacnt_com_cd
		JOIN tblRKFutureMarket FM ON FM.strFutSymbol COLLATE SQL_Latin1_General_CP1_CS_AS = CM.gacom_dflt_bot COLLATE SQL_Latin1_General_CP1_CS_AS
		LEFT JOIN tblRKFuturesMonth FMN ON FMN.intFutureMarketId = FM.intFutureMarketId AND FMN.strFutureMonth COLLATE SQL_Latin1_General_CP1_CS_AS 
										= SUBSTRING(gacnt_bot_option,1,3)+' '+SUBSTRING(gacnt_bot_option,4,2) COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE gacnt_bot_option IS NOT NULL AND FMN.intFutureMonthId is NULL
END
GO