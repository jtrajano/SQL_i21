﻿CREATE TABLE [dbo].[ssascmst] (
    [ssasc_code]        CHAR (1)    NOT NULL,
    [ssasc_desc]        CHAR (15)   NULL,
    [ssasc_user_id]     CHAR (16)   NULL,
    [ssasc_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_ssascmst] PRIMARY KEY NONCLUSTERED ([ssasc_code] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Issascmst0]
    ON [dbo].[ssascmst]([ssasc_code] ASC);

