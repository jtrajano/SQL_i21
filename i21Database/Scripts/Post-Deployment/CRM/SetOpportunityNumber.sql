﻿GO
	PRINT N'Begin updating opportunities with no opportunity number.';
GO

	IF EXISTS (SELECT * FROM tblSMStartingNumber WHERE strPrefix = 'OP-')
	BEGIN
		WHILE (SELECT COUNT(*) FROM tblCRMOpportunity WHERE strOpportunityNumber IS NULL) > 0
		BEGIN
			DECLARE @output NVARCHAR(40)

			EXEC uspSMGetStartingNumber 180, @output OUTPUT
			UPDATE tblCRMOpportunity SET strOpportunityNumber = @output WHERE intOpportunityId = (SELECT TOP 1 intOpportunityId FROM tblCRMOpportunity WHERE strOpportunityNumber IS NULL ORDER BY intOpportunityId)
		END
	END

GO
	PRINT N'End udpating opportunities with no opportunity number.';
GO