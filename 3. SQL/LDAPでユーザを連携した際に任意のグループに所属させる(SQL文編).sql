-- SQL文2:無効でない、かつメールアドレスが特定のドメインのユーザー情報を取得
/*
* GroupMembersテーブルの書式：
    [GroupId]
    ,[DeptId]
    ,[UserId]
    ,[Ver]
    ,[Admin]
    ,[Comments]
    ,[Creator]
    ,[Updator]
    ,[CreatedTime]
    ,[UpdatedTime]
*/
select [GroupId] = 7,[DeptId] = 0,[OwnerId],[Ver],[Admin] = 0,[Comments],[Creator],[Updator],[CreatedTime],[UpdatedTime] from [Implem.Pleasanter].[dbo].[MailAddresses] where [MailAddress] like '%@LDAP.co.jp' and [OwnerId] in (select [UserId] from [Implem.Pleasanter].[dbo].[Users] where [Lockout] = '0')

-- SQL文1:無効でないユーザーのuserIdを取得(ローカルで動作検証済み)
select [UserId] from [Implem.Pleasanter].[dbo].[Users] where [Lockout] = '0'



-- ↓実装で必要になるSQL文(ローカルで動作検証済み)

-- GroupMembersテーブルのメンバーを削除
delete from [Implem.Pleasanter].[dbo].[GroupMembers] where [GroupId] = 7;

-- SQL文3:無効でない、かつメールアドレスが特定のドメインのユーザー情報を挿入(ローカルで動作検証済み)
insert into [Implem.Pleasanter].[dbo].[GroupMembers] select [GroupId] = 7,[DeptId] = 0,[OwnerId],[Ver],[Admin] = 0,[Comments],[Creator],[Updator],[CreatedTime],[UpdatedTime] from [Implem.Pleasanter].[dbo].[MailAddresses] where [MailAddress] like '%@LDAP.co.jp' and [OwnerId] in (select [UserId] from [Implem.Pleasanter].[dbo].[Users] where [Lockout] = '0');