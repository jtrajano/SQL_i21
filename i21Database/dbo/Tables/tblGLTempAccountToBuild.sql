CREATE TABLE [dbo].[tblGLTempAccountToBuild] (
    [cntID]               INT      IDENTITY (1, 1) NOT NULL,
    [intAccountSegmentID] INT      NOT NULL,
    [intUserID]           INT      NOT NULL,
    [dtmCreated]          DATETIME CONSTRAINT [DF_tblTempGLAccountToBuild_dtmCreated] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_tblTempGLAccountToBuild] PRIMARY KEY CLUSTERED ([cntID] ASC)
);

