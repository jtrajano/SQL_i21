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


 END
GO