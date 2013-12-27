﻿CREATE TABLE [dbo].[gasxfmst] (
    [gasxf_pur_sls_ind]     CHAR (1)        NOT NULL,
    [gasxf_cus_no]          CHAR (10)       NOT NULL,
    [gasxf_com_cd]          CHAR (3)        NOT NULL,
    [gasxf_stor_type]       TINYINT         NOT NULL,
    [gasxf_tic_no]          CHAR (10)       NOT NULL,
    [gasxf_loc_no]          CHAR (3)        NOT NULL,
    [gasxf_tie_breaker]     SMALLINT        NOT NULL,
    [gasxf_seq_no]          SMALLINT        NOT NULL,
    [gasxf_rev_dt]          INT             NULL,
    [gasxf_in_out_ind]      CHAR (1)        NULL,
    [gasxf_io_tic_no]       CHAR (10)       NULL,
    [gasxf_io_cus_no_1]     CHAR (10)       NULL,
    [gasxf_io_cus_no_2]     CHAR (10)       NULL,
    [gasxf_io_cus_no_3]     CHAR (10)       NULL,
    [gasxf_io_cus_no_4]     CHAR (10)       NULL,
    [gasxf_io_cus_no_5]     CHAR (10)       NULL,
    [gasxf_io_cus_no_6]     CHAR (10)       NULL,
    [gasxf_io_cus_no_7]     CHAR (10)       NULL,
    [gasxf_io_cus_no_8]     CHAR (10)       NULL,
    [gasxf_io_cus_no_9]     CHAR (10)       NULL,
    [gasxf_io_cus_no_10]    CHAR (10)       NULL,
    [gasxf_io_cus_no_11]    CHAR (10)       NULL,
    [gasxf_io_cus_no_12]    CHAR (10)       NULL,
    [gasxf_un_1]            DECIMAL (11, 3) NULL,
    [gasxf_un_2]            DECIMAL (11, 3) NULL,
    [gasxf_un_3]            DECIMAL (11, 3) NULL,
    [gasxf_un_4]            DECIMAL (11, 3) NULL,
    [gasxf_un_5]            DECIMAL (11, 3) NULL,
    [gasxf_un_6]            DECIMAL (11, 3) NULL,
    [gasxf_un_7]            DECIMAL (11, 3) NULL,
    [gasxf_un_8]            DECIMAL (11, 3) NULL,
    [gasxf_un_9]            DECIMAL (11, 3) NULL,
    [gasxf_un_10]           DECIMAL (11, 3) NULL,
    [gasxf_un_11]           DECIMAL (11, 3) NULL,
    [gasxf_un_12]           DECIMAL (11, 3) NULL,
    [gasxf_io_stor_type_1]  TINYINT         NULL,
    [gasxf_io_stor_type_2]  TINYINT         NULL,
    [gasxf_io_stor_type_3]  TINYINT         NULL,
    [gasxf_io_stor_type_4]  TINYINT         NULL,
    [gasxf_io_stor_type_5]  TINYINT         NULL,
    [gasxf_io_stor_type_6]  TINYINT         NULL,
    [gasxf_io_stor_type_7]  TINYINT         NULL,
    [gasxf_io_stor_type_8]  TINYINT         NULL,
    [gasxf_io_stor_type_9]  TINYINT         NULL,
    [gasxf_io_stor_type_10] TINYINT         NULL,
    [gasxf_io_stor_type_11] TINYINT         NULL,
    [gasxf_io_stor_type_12] TINYINT         NULL,
    [gasxf_stor_schd_1]     TINYINT         NULL,
    [gasxf_stor_schd_2]     TINYINT         NULL,
    [gasxf_stor_schd_3]     TINYINT         NULL,
    [gasxf_stor_schd_4]     TINYINT         NULL,
    [gasxf_stor_schd_5]     TINYINT         NULL,
    [gasxf_stor_schd_6]     TINYINT         NULL,
    [gasxf_stor_schd_7]     TINYINT         NULL,
    [gasxf_stor_schd_8]     TINYINT         NULL,
    [gasxf_stor_schd_9]     TINYINT         NULL,
    [gasxf_stor_schd_10]    TINYINT         NULL,
    [gasxf_stor_schd_11]    TINYINT         NULL,
    [gasxf_stor_schd_12]    TINYINT         NULL,
    [gasxf_user_id]         CHAR (16)       NULL,
    [gasxf_user_rev_dt]     INT             NULL,
    [A4GLIdentity]          NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gasxfmst] PRIMARY KEY NONCLUSTERED ([gasxf_pur_sls_ind] ASC, [gasxf_cus_no] ASC, [gasxf_com_cd] ASC, [gasxf_stor_type] ASC, [gasxf_tic_no] ASC, [gasxf_loc_no] ASC, [gasxf_tie_breaker] ASC, [gasxf_seq_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Igasxfmst0]
    ON [dbo].[gasxfmst]([gasxf_pur_sls_ind] ASC, [gasxf_cus_no] ASC, [gasxf_com_cd] ASC, [gasxf_stor_type] ASC, [gasxf_tic_no] ASC, [gasxf_loc_no] ASC, [gasxf_tie_breaker] ASC, [gasxf_seq_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gasxfmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gasxfmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gasxfmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gasxfmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[gasxfmst] TO PUBLIC
    AS [dbo];

