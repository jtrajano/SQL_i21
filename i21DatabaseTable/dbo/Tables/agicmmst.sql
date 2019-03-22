CREATE TABLE [dbo].[agicmmst] (
    [agicm_itm_no]        CHAR (13)   NOT NULL,
    [agicm_loc_no]        CHAR (3)    NOT NULL,
    [agicm_ivc_comment_1] CHAR (33)   NULL,
    [agicm_ivc_comment_2] CHAR (33)   NULL,
    [agicm_ivc_comment_3] CHAR (33)   NULL,
    [agicm_ivc_comment_4] CHAR (33)   NULL,
    [agicm_ivc_comment_5] CHAR (33)   NULL,
    [agicm_pic_comment_1] CHAR (33)   NULL,
    [agicm_pic_comment_2] CHAR (33)   NULL,
    [agicm_pic_comment_3] CHAR (33)   NULL,
    [agicm_pic_comment_4] CHAR (33)   NULL,
    [agicm_pic_comment_5] CHAR (33)   NULL,
    [agicm_user_id]       CHAR (16)   NULL,
    [agicm_user_rev_dt]   INT         NULL,
    [A4GLIdentity]        NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agicmmst] PRIMARY KEY NONCLUSTERED ([agicm_itm_no] ASC, [agicm_loc_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagicmmst0]
    ON [dbo].[agicmmst]([agicm_itm_no] ASC, [agicm_loc_no] ASC);

