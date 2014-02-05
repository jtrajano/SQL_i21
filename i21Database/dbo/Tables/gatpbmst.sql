CREATE TABLE [dbo].[gatpbmst] (
    [gatpb_com_cd]            CHAR (3)       NOT NULL,
    [gatpb_due_yyyymm]        INT            NOT NULL,
    [gatpb_loc_no]            CHAR (3)       NOT NULL,
    [gatpb_mkt_zone]          CHAR (3)       NOT NULL,
    [gatpb_bot]               CHAR (1)       NOT NULL,
    [gatpb_bot_option]        CHAR (5)       NOT NULL,
    [gatpb_un_bot_buy_basis]  DECIMAL (9, 5) NULL,
    [gatpb_un_bot_sell_basis] DECIMAL (9, 5) NULL,
    [gatpb_un_dlr_bot_basis]  DECIMAL (9, 5) NULL,
    [gatpb_user_id]           CHAR (16)      NULL,
    [gatpb_user_rev_dt]       INT            NULL,
    [A4GLIdentity]            NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gatpbmst] PRIMARY KEY NONCLUSTERED ([gatpb_com_cd] ASC, [gatpb_due_yyyymm] ASC, [gatpb_loc_no] ASC, [gatpb_mkt_zone] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igatpbmst0]
    ON [dbo].[gatpbmst]([gatpb_com_cd] ASC, [gatpb_due_yyyymm] ASC, [gatpb_loc_no] ASC, [gatpb_mkt_zone] ASC);


GO
CREATE NONCLUSTERED INDEX [Igatpbmst1]
    ON [dbo].[gatpbmst]([gatpb_bot] ASC, [gatpb_bot_option] ASC);

