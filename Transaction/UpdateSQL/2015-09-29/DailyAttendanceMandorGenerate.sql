
/****** Object:  StoredProcedure [Checkroll].[DailyAttendanceMandorGenerate]    Script Date: 29/9/2015 7:56:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [Checkroll].[DailyAttendanceMandorGenerate]
	-- Add the parameters for the stored procedure here
	@EstateID as nvarchar(50),
	@DDAte as date
AS
BEGIN
	SELECT         EmpID, EmpCode, EmpName, General.EmpJobDescription.Description
FROM            Checkroll.CREmployee INNER JOIN
                         General.EmpJobDescription ON Checkroll.CREmployee.EmpJobDescriptionId = General.EmpJobDescription.Id where CREmployee.EmpJobDescriptionId <> 1 and EstateID = @EstateID
UNION 
--Normal Employee becomes Mandor
	SELECT         EmpID, EmpCode, EmpName, General.EmpJobDescription.Description
FROM            Checkroll.CREmployee INNER JOIN
                         General.EmpJobDescription ON Checkroll.CREmployee.EmpJobDescriptionId = General.EmpJobDescription.Id 
INNER JOIN
                         Checkroll.DailyTeamActivity ON Checkroll.CREmployee.EmpID = Checkroll.DailyTeamActivity.MandoreID 
where CREmployee.EmpJobDescriptionId = 1 and Checkroll.CREmployee.EstateID = @EstateID and Checkroll.DailyTeamActivity.DDate = @DDAte
UNION
SELECT         EmpID, EmpCode, EmpName, General.EmpJobDescription.Description
FROM            Checkroll.CREmployee INNER JOIN
                         General.EmpJobDescription ON Checkroll.CREmployee.EmpJobDescriptionId = General.EmpJobDescription.Id 
INNER JOIN
                         Checkroll.DailyTeamActivity ON Checkroll.CREmployee.EmpID = Checkroll.DailyTeamActivity.KraniID
where CREmployee.EmpJobDescriptionId = 1 and Checkroll.CREmployee.EstateID = @EstateID and Checkroll.DailyTeamActivity.DDate = @DDAte
END


