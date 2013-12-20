CREATE TABLE [dbo].[bfposmst] (
    [bfpos_loc_no]      CHAR (3)        NOT NULL,
    [bfpos_pos_type]    TINYINT         NOT NULL,
    [bfpos_com_cd]      CHAR (3)        NOT NULL,
    [bfpos_seq_no]      SMALLINT        NOT NULL,
    [bfpos_column_no]   TINYINT         NOT NULL,
    [bfpos_cnt_type]    CHAR (1)        NOT NULL,
    [bfpos_rec_type]    CHAR (1)        NOT NULL,
    [bfpos_opt_year]    TINYINT         NOT NULL,
    [bfpos_opt_month]   CHAR (3)        NOT NULL,
    [bfpos_un]          DECIMAL (13, 3) NULL,
    [bfpos_un_waf]      DECIMAL (11, 5) NULL,
    [bfpos_un_wab]      DECIMAL (11, 5) NULL,
    [bfpos_un_wac]      DECIMAL (11, 5) NULL,
    [bfpos_pct]         DECIMAL (5, 2)  NULL,
    [bfpos_override_yn] CHAR (1)        NULL,
    [A4GLIdentity]      NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_bfposmst] PRIMARY KEY NONCLUSTERED ([bfpos_loc_no] ASC, [bfpos_pos_type] ASC, [bfpos_com_cd] ASC, [bfpos_seq_no] ASC, [bfpos_column_no] ASC, [bfpos_cnt_type] ASC, [bfpos_rec_type] ASC, [bfpos_opt_year] ASC, [bfpos_opt_month] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ibfposmst0]
    ON [dbo].[bfposmst]([bfpos_loc_no] ASC, [bfpos_pos_type] ASC, [bfpos_com_cd] ASC, [bfpos_seq_no] ASC, [bfpos_column_no] ASC, [bfpos_cnt_type] ASC, [bfpos_rec_type] ASC, [bfpos_opt_year] ASC, [bfpos_opt_month] ASC);

