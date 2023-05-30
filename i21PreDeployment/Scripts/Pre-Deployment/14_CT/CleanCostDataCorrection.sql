IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'tblCTCleanCost')
BEGIN
  exec sp_executesql N'UPDATE  tblCTCleanCost SET intShipmentId = NULL 
  WHERE intShipmentId NOT IN (SELECT intLoadDetailId from tblLGLoadDetail)'
END
GO
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'tblCTContractPlan')
BEGIN
 exec sp_executesql N'UPDATE tblCTContractPlan SET intWeightId = NULL WHERE intWeightId NOT IN (SELECT intWeightGradeId FROM tblCTWeightGrade)'
 exec sp_executesql N'UPDATE tblCTContractPlan SET intGradeId = NULL WHERE intGradeId NOT IN (SELECT intWeightGradeId FROM tblCTWeightGrade)'

 exec('
	IF (OBJECT_ID(''dbo.FK_tblCTContractPlan_tblCTContractBasis_intContractBasisId'', ''F'') IS NOT NULL)
	BEGIN
		ALTER TABLE tblCTContractPlan DROP CONSTRAINT FK_tblCTContractPlan_tblCTContractBasis_intContractBasisId;
	END

	update
		a
	set
		a.intContractBasisId = c.intFreightTermId
	from
		tblCTContractPlan a
		,tblCTContractBasis b
		,tblSMFreightTerms c
	where
		b.intContractBasisId = a.intContractBasisId
		and c.strFreightTerm = b.strContractBasis
 ');

IF EXISTS(SELECT * FROM sys.columns  WHERE name = N'intPricingStatus' AND object_id = OBJECT_ID(N'tblCTContractDetail'))
BEGIN
	IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trgCTContractDetail')
	BEGIN
		exec
		('

			ALTER TABLE tblCTContractDetail DISABLE TRIGGER trgCTContractDetail;

			update a set
			intPricingStatus = (
								case
									when a.intPricingTypeId = 1
									then 2
									else
										(
										case
											when pricing.dblQuantity > pricing.dblPricedQuantity
											then 1
											when pricing.dblQuantity >= pricing.dblPricedQuantity
											then 2
											else 0
										end
										)
								end
								)
			from
			tblCTContractDetail a
			left join
			(
				select
				cd.intContractDetailId
				,cd.intPricingTypeId
				,cd.dblQuantity
				,dblPricedQuantity = sum(pfd.dblQuantity)
				from tblCTContractDetail cd, tblCTPriceFixation pf, tblCTPriceFixationDetail pfd
				where
				cd.intPricingTypeId <> 1
				and pf.intContractDetailId = cd.intContractDetailId
				and pfd.intPriceFixationId = pf.intPriceFixationId
				group by
				cd.intContractDetailId
				,cd.intPricingTypeId
				,cd.dblQuantity
			) as pricing on pricing.intContractDetailId = a.intContractDetailId
			where
			a.intPricingStatus is null;

			ALTER TABLE tblCTContractDetail ENABLE TRIGGER trgCTContractDetail;
			
		');
	END
	
	IF EXISTS(SELECT * FROM sys.columns  WHERE name = N'intDailyAveragePriceDetailId' AND object_id = OBJECT_ID(N'tblCTPriceFixationDetail'))
		AND EXISTS(SELECT * FROM sys.columns  WHERE name = N'intDailyAveragePriceDetailId' AND object_id = OBJECT_ID(N'tblRKDailyAveragePriceDetail')) 
	BEGIN
		EXEC 
		('
			update tblCTPriceFixationDetail set intDailyAveragePriceDetailId = null where intDailyAveragePriceDetailId not in 
			(
				select intDailyAveragePriceDetailId from tblRKDailyAveragePriceDetail
			)
		');
	END
END
END
GO
	IF EXISTS(SELECT * FROM sys.columns  WHERE name = N'intPrevConcurrencyId' AND object_id = OBJECT_ID(N'tblCTContractCost'))
	BEGIN
		EXEC 
		('
			update tblCTContractCost set intPrevConcurrencyId = 0 where intPrevConcurrencyId is null
		');
	END
GO
	IF EXISTS(SELECT * FROM sys.columns  WHERE name = N'intBookId' AND object_id = OBJECT_ID(N'tblCTRawToWipConversion'))
	BEGIN
		EXEC 
		('
			DELETE FROM tblCTRawToWipConversion WHERE intBookId NOT IN (SELECT DISTINCT intBookId FROM tblCTBook)
		');
	END
GO
	IF EXISTS(SELECT * FROM sys.columns  WHERE name = N'intSubBookId' AND object_id = OBJECT_ID(N'tblCTRawToWipConversion'))
	BEGIN
		EXEC 
		('
			DELETE FROM tblCTRawToWipConversion WHERE intSubBookId NOT IN (SELECT DISTINCT intSubBookId FROM tblCTSubBook)
		');
	END
GO
	IF EXISTS(SELECT * FROM sys.columns  WHERE name = N'intFuturesMarketId' AND object_id = OBJECT_ID(N'tblCTRawToWipConversion'))
	BEGIN
		EXEC 
		('
			DELETE FROM tblCTRawToWipConversion WHERE intFuturesMarketId NOT IN (SELECT DISTINCT intFutureMarketId FROM tblRKFutureMarket)
		');
	END
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblCTContractDetail')
	BEGIN
		EXEC 
		('
			update d set
			d.intPricingTypeId =
				case
				when h.intPricingTypeId = 5 then 5
				else
					case
					when d.dblBasis is null and d.dblFutures is null and d.dblCashPrice is null then 4
					when d.dblBasis is not null and d.dblFutures is null and d.dblCashPrice is null then 2
					when d.dblBasis is not null and d.dblFutures is not null and d.dblCashPrice is not null then 1
					when d.dblBasis is null and d.dblFutures is not null and d.dblCashPrice is null then 3
					when d.dblBasis is null and d.dblFutures is null and d.dblCashPrice is not null then 6
					else h.intPricingTypeId
					end
				end
			from tblCTContractDetail d
			join tblCTContractHeader h on h.intContractHeaderId = d.intContractHeaderId
			where d.intPricingTypeId is null
		');
	END
GO