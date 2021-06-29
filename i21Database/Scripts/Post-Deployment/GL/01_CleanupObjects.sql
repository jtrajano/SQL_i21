PRINT 'Begin GL Clean up Objects - Drop obsolete objects'
GO

IF object_id('fnGLGetRelativeDatabase', 'FN') IS NOT NULL
BEGIN
    DROP FUNCTION [dbo].[fnGLGetRelativeDatabase]
END
GO


PRINT 'End GL Clean up Objects - Drop obsolete objects'
GO
