
GO
/****** Object:  StoredProcedure [Checkroll].[DailyTeamActivityisExist]    Script Date: 02/02/2015 9:41:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [Checkroll].[DailyTeamActivityisExist]
@EstateID nvarchar(50),
@DDate date
	
	
AS
BEGIN
SELECT        Checkroll.DailyTeamActivity.DDate AS Date, Checkroll.DailyTeamActivity.DailyTeamActivityID AS [Daily Team Activity ID], 
                         Checkroll.DailyTeamActivity.GangMasterID AS [Gang Master Id], Checkroll.DailyTeamActivity.EstateID AS [Estate Id], General.Estate.EstateCode AS [Estate Code], 
                         Checkroll.DailyTeamActivity.GangName AS [Team Name], Checkroll.DailyTeamActivity.Activity, Checkroll.DailyTeamActivity.MandoreID AS [Mandore ID], 
                         CREmployee_2.EmpID AS [Emp ID Mandor], CREmployee_2.EmpCode AS [Mandor NIK], CREmployee_2.EmpName AS Mandor, 
                         Checkroll.DailyTeamActivity.KraniID AS [Krani ID], CREmployee_1.EmpID AS [Emp ID Krani], CREmployee_1.EmpCode AS [Krani NIK], 
                         CREmployee_1.EmpName AS Krani, Checkroll.DailyTeamActivity.CreatedBy AS [Created By], Checkroll.DailyTeamActivity.CreatedOn AS [Created On], 
                         Checkroll.DailyTeamActivity.ModifiedBy AS [Modified By], Checkroll.DailyTeamActivity.ModifiedOn AS [Modified On], 
                         Checkroll.DailyTeamActivity.MandorBesarID AS [Mandor Besar ID], Checkroll.CREmployee.EmpID AS [Emp ID Mandor Besar], 
                         Checkroll.CREmployee.EmpCode AS [Mandor Besar NIK], Checkroll.CREmployee.EmpName AS [Mandor Besar]
FROM            Checkroll.DailyTeamActivity INNER JOIN
                         General.Estate ON Checkroll.DailyTeamActivity.EstateID = General.Estate.EstateID FULL OUTER JOIN
                         Checkroll.CREmployee ON Checkroll.DailyTeamActivity.MandorBesarID = Checkroll.CREmployee.EmpID FULL OUTER JOIN
                         Checkroll.CREmployee AS CREmployee_2 ON Checkroll.DailyTeamActivity.MandoreID = CREmployee_2.EmpID FULL OUTER JOIN
                         Checkroll.CREmployee AS CREmployee_1 ON Checkroll.DailyTeamActivity.KraniID = CREmployee_1.EmpID
WHERE Checkroll.DailyTeamActivity.EstateID  = @EstateID and  CONVERT(DATE,DDate)= @DDate 
END










