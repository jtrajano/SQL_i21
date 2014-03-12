CREATE TABLE [dbo].[tblGLTempAccountToBuild] (
    [cntId]               INT      IDENTITY (1, 1) NOT NULL,
    [intAccountSegmentId] INT      NOT NULL,
    [intUserId]           INT      NOT NULL,
    [dtmCreated]          DATETIME CONSTRAINT [DF_tblTempGLAccountToBuild_dtmCreated] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_tblTempGLAccountToBuild] PRIMARY KEY CLUSTERED ([cntId] ASC)
);

