--liquibase formatted sql

-- changeset Von:fnCTCoalesceCertificates.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnCTCoalesceCertificates](@intContractDetailId int)
RETURNS nvarchar(max)
AS
BEGIN

	DECLARE @strCertificates nvarchar(max);

	select
		@strCertificates = coalesce(@strCertificates + ',', '') +  b.strCertificationName
	from
		tblCTContractCertification a
		inner join tblICCertification b on a.intCertificationId = b.intCertificationId
	where
		a.intContractDetailId = @intContractDetailId
		and b.strCertificationName is not null

	return @strCertificates

END



