CREATE PROCEDURE uspGLMergeSegmentAccount
(
  @ysnMergeCOA BIT = 0,
  @ysnClear BIT = 0
)
AS
BEGIN
    	SET XACT_ABORT ON

      IF EXISTS(SELECT 1 FROM sys.triggers WHERE [Name] = 'trg_tblGLAccountSegment')
      BEGIN
        ALTER TABLE tblGLAccountSegment
        DISABLE TRIGGER trg_tblGLAccountSegment
      END
      
      EXEC uspGLMergeSegmentAccount2 @ysnMergeCOA, @ysnClear

      IF EXISTS(SELECT 1 FROM sys.triggers WHERE [Name] = 'trg_tblGLAccountSegment')
      BEGIN
        ALTER TABLE tblGLAccountSegment
        ENABLE TRIGGER trg_tblGLAccountSegment
      END

      
      IF @ysnMergeCOA = 1
          EXEC uspGLMergeGLAccount @ysnClear
      
      
END