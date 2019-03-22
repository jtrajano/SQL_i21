CREATE TABLE [dbo].[prcmtmst] (
    [prcmt_emp]         CHAR (10)   NOT NULL,
    [prcmt_date]        INT         NOT NULL,
    [prcmt_time]        INT         NOT NULL,
    [prcmt_seq]         SMALLINT    NOT NULL,
    [prcmt_line]        CHAR (78)   NULL,
    [prcmt_user_id]     CHAR (16)   NULL,
    [prcmt_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_prcmtmst] PRIMARY KEY NONCLUSTERED ([prcmt_emp] ASC, [prcmt_date] ASC, [prcmt_time] ASC, [prcmt_seq] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iprcmtmst0]
    ON [dbo].[prcmtmst]([prcmt_emp] ASC, [prcmt_date] ASC, [prcmt_time] ASC, [prcmt_seq] ASC);

