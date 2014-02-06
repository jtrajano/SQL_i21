CREATE TABLE [dbo].[pxtcnmst] (
    [pxtcn_state]       CHAR (2)    NOT NULL,
    [pxtcn_term_cd]     CHAR (9)    NOT NULL,
    [pxtcn_name]        CHAR (40)   NULL,
    [pxtcn_addr]        CHAR (30)   NULL,
    [pxtcn_city]        CHAR (20)   NULL,
    [pxtcn_zip]         CHAR (9)    NULL,
    [pxtcn_user_id]     CHAR (16)   NULL,
    [pxtcn_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_pxtcnmst] PRIMARY KEY NONCLUSTERED ([pxtcn_state] ASC, [pxtcn_term_cd] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ipxtcnmst0]
    ON [dbo].[pxtcnmst]([pxtcn_state] ASC, [pxtcn_term_cd] ASC);

