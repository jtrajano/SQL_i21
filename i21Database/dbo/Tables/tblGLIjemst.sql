﻿CREATE TABLE [dbo].[tblGLIjemst] (
    [glije_period]      INT             NOT NULL,
    [glije_acct_no]     DECIMAL (16, 8) NOT NULL,
    [glije_src_sys]     CHAR (3)        NOT NULL,
    [glije_src_no]      CHAR (5)        NOT NULL,
    [glije_line_no]     INT             NOT NULL,
    [glije_date]        INT             NULL,
    [glije_time]        INT             NULL,
    [glije_ref]         CHAR (25)       NULL,
    [glije_doc]         CHAR (25)       NULL,
    [glije_comments]    CHAR (25)       NULL,
    [glije_dr_cr_ind]   CHAR (1)        NULL,
    [glije_amt]         DECIMAL (12, 2) NULL,
    [glije_units]       DECIMAL (16, 4) NULL,
    [glije_correcting]  CHAR (1)        NULL,
    [glije_source_pgm]  CHAR (8)        NULL,
    [glije_work_area]   CHAR (40)       NULL,
    [glije_cbk_no]      CHAR (2)        NULL,
    [glije_user_id]     CHAR (16)       NULL,
    [glije_user_rev_dt] INT             NULL,
    [A4GLIdentity]      NUMERIC (9)     NOT NULL, 
	[glije_uid] [uniqueidentifier] NULL,
    [glije_postdate] DATE NULL, 
    [glije_id] INT NOT NULL IDENTITY, 
    [glije_dte] DATETIME NULL, 
    [glije_error_desc] NVARCHAR(300) NULL 
);

