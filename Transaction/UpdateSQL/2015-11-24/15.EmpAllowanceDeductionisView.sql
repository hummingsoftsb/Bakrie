/****** Object:  StoredProcedure [Checkroll].[EmpAllowanceDeductionisView]    Script Date: 26/11/2015 9:49:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---- modified by : Kumaravel
---Modified On : jul 8 2010
-- =============================================
ALTER PROCEDURE [Checkroll].[EmpAllowanceDeductionisView]
	-- Add the parameters for the stored procedure here
	@StartDate date,
	@EndDate date,
	@EstateID nvarchar(50),
	@EmpId nvarchar(50),
	@AllowDedID nvarchar(50)

AS

	
	
	SET NOCOUNT ON;
	
	--IF (@EmpId IS NULL and @AllowDedID IS NULL)
	IF (@EmpId = '' and @AllowDedID = '') 
	BEGIN
	
	
		SELECT     Checkroll.EmpAllowanceDeduction.EmpAllowDedID AS [Emp Allow Ded ID], Checkroll.EmpAllowanceDeduction.EstateID AS [Estate ID], 
                      General.Estate.EstateCode AS [Estate Code], Checkroll.EmpAllowanceDeduction.EmpID AS [Employee ID], 
                      Checkroll.CREmployee.EmpCode AS [Employee Code], Checkroll.CREmployee.EmpName AS [Employee Name], 
                      Checkroll.EmpAllowanceDeduction.AllowDedID AS [Allow Ded ID], Checkroll.AllowanceDeductionSetup.AllowDedCode AS [Allow Ded Code], 
                      Checkroll.AllowanceDeductionSetup.Remarks, Checkroll.AllowanceDeductionSetup.COAID AS [COA Id], Accounts.COA.COACode AS [COA Code], 
                      Accounts.COA.COADescp AS [COA Descp], Checkroll.EmpAllowanceDeduction.Amount, Checkroll.EmpAllowanceDeduction.Type, 
                      Checkroll.EmpAllowanceDeduction.StartDate AS [Start Date], Checkroll.EmpAllowanceDeduction.EndDates AS [End Date], 
                      Checkroll.EmpAllowanceDeduction.CreatedBy AS [Created By], Checkroll.EmpAllowanceDeduction.CreatedOn AS [Created On], 
                      Checkroll.EmpAllowanceDeduction.ModifiedBy AS [Modified By], Checkroll.EmpAllowanceDeduction.ModifiedOn AS [Modified On]
FROM         Checkroll.EmpAllowanceDeduction 
					INNER JOIN Checkroll.CREmployee ON Checkroll.EmpAllowanceDeduction.EmpID = Checkroll.CREmployee.EmpID 
                    INNER JOIN Checkroll.AllowanceDeductionSetup ON Checkroll.EmpAllowanceDeduction.AllowDedID = Checkroll.AllowanceDeductionSetup.AllowDedID 
                    AND Checkroll.EmpAllowanceDeduction.AllowDedID = Checkroll.AllowanceDeductionSetup.AllowDedID 
                    INNER JOIN Accounts.COA ON Checkroll.AllowanceDeductionSetup.COAID = Accounts.COA.COAID 
                    INNER JOIN General.Estate ON Checkroll.EmpAllowanceDeduction.EstateID = General.Estate.EstateID
		
		WHERE 
		CONVERT(DATE,StartDate) >= @StartDate 
		and CONVERT(DATE,EndDates) <= @EndDate
		
		and EmpAllowanceDeduction.EstateID = @EstateID 
		And checkroll.AllowanceDeductionSetup.NoTransferToSalary = 0
		order by Checkroll.EmpAllowanceDeduction.StartDate Desc
		
	END
		
	--IF (@EmpId IS NOT NULL and @AllowDedID IS NULL)
	IF (@EmpId <> '' and @AllowDedID = '')
	BEGIN
		SELECT     Checkroll.EmpAllowanceDeduction.EmpAllowDedID AS [Emp Allow Ded ID], Checkroll.EmpAllowanceDeduction.EstateID AS [Estate ID], 
                      General.Estate.EstateCode AS [Estate Code], Checkroll.EmpAllowanceDeduction.EmpID AS [Employee ID], 
                      Checkroll.CREmployee.EmpCode AS [Employee Code], Checkroll.CREmployee.EmpName AS [Employee Name], 
                      Checkroll.EmpAllowanceDeduction.AllowDedID AS [Allow Ded ID], Checkroll.AllowanceDeductionSetup.AllowDedCode AS [Allow Ded Code], 
                      Checkroll.AllowanceDeductionSetup.Remarks, Checkroll.AllowanceDeductionSetup.COAID AS [COA Id], Accounts.COA.COACode AS [COA Code], 
                      Accounts.COA.COADescp AS [COA Descp], Checkroll.EmpAllowanceDeduction.Amount, Checkroll.EmpAllowanceDeduction.Type, 
                      Checkroll.EmpAllowanceDeduction.StartDate AS [Start Date], Checkroll.EmpAllowanceDeduction.EndDates AS [End Date], 
                      Checkroll.EmpAllowanceDeduction.CreatedBy AS [Created By], Checkroll.EmpAllowanceDeduction.CreatedOn AS [Created On], 
                      Checkroll.EmpAllowanceDeduction.ModifiedBy AS [Modified By], Checkroll.EmpAllowanceDeduction.ModifiedOn AS [Modified On]
FROM         Checkroll.EmpAllowanceDeduction INNER JOIN
                      Checkroll.CREmployee ON Checkroll.EmpAllowanceDeduction.EmpID = Checkroll.CREmployee.EmpID INNER JOIN
                      Checkroll.AllowanceDeductionSetup ON Checkroll.EmpAllowanceDeduction.AllowDedID = Checkroll.AllowanceDeductionSetup.AllowDedID AND 
                      Checkroll.EmpAllowanceDeduction.AllowDedID = Checkroll.AllowanceDeductionSetup.AllowDedID INNER JOIN
                      Accounts.COA ON Checkroll.AllowanceDeductionSetup.COAID = Accounts.COA.COAID INNER JOIN
                      General.Estate ON Checkroll.EmpAllowanceDeduction.EstateID = General.Estate.EstateID
		
		WHERE Checkroll.EmpAllowanceDeduction.EmpID = @EmpId 
		and CONVERT(DATE,StartDate) >= @StartDate 
		and CONVERT(DATE,EndDates) <= @EndDate
		And checkroll.AllowanceDeductionSetup.NoTransferToSalary = 0
			order by Checkroll.EmpAllowanceDeduction.StartDate Desc
			
	END
	--IF (@AllowDedID <> '' or @AllowDedID <> NULL)  and (@EmpId = '' or @EmpId = NULL)
	IF (@AllowDedID <> '' and @EmpId = '')
	BEGIN
		SELECT     Checkroll.EmpAllowanceDeduction.EmpAllowDedID AS [Emp Allow Ded ID], Checkroll.EmpAllowanceDeduction.EstateID AS [Estate ID], 
                      General.Estate.EstateCode AS [Estate Code], Checkroll.EmpAllowanceDeduction.EmpID AS [Employee ID], 
                      Checkroll.CREmployee.EmpCode AS [Employee Code], Checkroll.CREmployee.EmpName AS [Employee Name], 
                      Checkroll.EmpAllowanceDeduction.AllowDedID AS [Allow Ded ID], Checkroll.AllowanceDeductionSetup.AllowDedCode AS [Allow Ded Code], 
                      Checkroll.AllowanceDeductionSetup.Remarks, Checkroll.AllowanceDeductionSetup.COAID AS [COA Id], Accounts.COA.COACode AS [COA Code], 
                      Accounts.COA.COADescp AS [COA Descp], Checkroll.EmpAllowanceDeduction.Amount, Checkroll.EmpAllowanceDeduction.Type, 
                      Checkroll.EmpAllowanceDeduction.StartDate AS [Start Date], Checkroll.EmpAllowanceDeduction.EndDates AS [End Date], 
                      Checkroll.EmpAllowanceDeduction.CreatedBy AS [Created By], Checkroll.EmpAllowanceDeduction.CreatedOn AS [Created On], 
                      Checkroll.EmpAllowanceDeduction.ModifiedBy AS [Modified By], Checkroll.EmpAllowanceDeduction.ModifiedOn AS [Modified On]
FROM         Checkroll.EmpAllowanceDeduction INNER JOIN
                      Checkroll.CREmployee ON Checkroll.EmpAllowanceDeduction.EmpID = Checkroll.CREmployee.EmpID INNER JOIN
                      Checkroll.AllowanceDeductionSetup ON Checkroll.EmpAllowanceDeduction.AllowDedID = Checkroll.AllowanceDeductionSetup.AllowDedID AND 
                      Checkroll.EmpAllowanceDeduction.AllowDedID = Checkroll.AllowanceDeductionSetup.AllowDedID INNER JOIN
                      Accounts.COA ON Checkroll.AllowanceDeductionSetup.COAID = Accounts.COA.COAID INNER JOIN
                      General.Estate ON Checkroll.EmpAllowanceDeduction.EstateID = General.Estate.EstateID
		
		WHERE Checkroll.EmpAllowanceDeduction.AllowDedID   = @AllowDedID
		 and CONVERT(DATE,StartDate) >= @StartDate 
		 and CONVERT(DATE,EndDates) <= @EndDate
		 And checkroll.AllowanceDeductionSetup.NoTransferToSalary = 0
		 	order by Checkroll.EmpAllowanceDeduction.StartDate Desc
	END



	--if (@EmpId <> '' or @EmpId <> NULL) and (@AllowDedID <> '' or @AllowDedID <> NULL)
	if (@EmpId <> '' and @AllowDedID <> '')
	BEGIN
		SELECT     Checkroll.EmpAllowanceDeduction.EmpAllowDedID AS [Emp Allow Ded ID], Checkroll.EmpAllowanceDeduction.EstateID AS [Estate ID], 
                      General.Estate.EstateCode AS [Estate Code], Checkroll.EmpAllowanceDeduction.EmpID AS [Employee ID], 
                      Checkroll.CREmployee.EmpCode AS [Employee Code], Checkroll.CREmployee.EmpName AS [Employee Name], 
                      Checkroll.EmpAllowanceDeduction.AllowDedID AS [Allow Ded ID], Checkroll.AllowanceDeductionSetup.AllowDedCode AS [Allow Ded Code], 
                      Checkroll.AllowanceDeductionSetup.Remarks, Checkroll.AllowanceDeductionSetup.COAID AS [COA Id], Accounts.COA.COACode AS [COA Code], 
                      Accounts.COA.COADescp AS [COA Descp], Checkroll.EmpAllowanceDeduction.Amount, Checkroll.EmpAllowanceDeduction.Type, 
                      Checkroll.EmpAllowanceDeduction.StartDate AS [Start Date], Checkroll.EmpAllowanceDeduction.EndDates AS [End Date], 
                      Checkroll.EmpAllowanceDeduction.CreatedBy AS [Created By], Checkroll.EmpAllowanceDeduction.CreatedOn AS [Created On], 
                      Checkroll.EmpAllowanceDeduction.ModifiedBy AS [Modified By], Checkroll.EmpAllowanceDeduction.ModifiedOn AS [Modified On]
FROM         Checkroll.EmpAllowanceDeduction INNER JOIN
                      Checkroll.CREmployee ON Checkroll.EmpAllowanceDeduction.EmpID = Checkroll.CREmployee.EmpID INNER JOIN
                      Checkroll.AllowanceDeductionSetup ON Checkroll.EmpAllowanceDeduction.AllowDedID = Checkroll.AllowanceDeductionSetup.AllowDedID AND 
                      Checkroll.EmpAllowanceDeduction.AllowDedID = Checkroll.AllowanceDeductionSetup.AllowDedID INNER JOIN
                      Accounts.COA ON Checkroll.AllowanceDeductionSetup.COAID = Accounts.COA.COAID INNER JOIN
                      General.Estate ON Checkroll.EmpAllowanceDeduction.EstateID = General.Estate.EstateID
		
		WHERE CONVERT(DATE,StartDate) >= @StartDate and CONVERT(DATE,EndDates) <= @EndDate and EmpAllowanceDeduction.EstateID = @EstateID 
		and Checkroll.EmpAllowanceDeduction.EmpID = @EmpId  and Checkroll.EmpAllowanceDeduction.AllowDedID   = @AllowDedID
		And checkroll.AllowanceDeductionSetup.NoTransferToSalary = 0
		order by Checkroll.EmpAllowanceDeduction.StartDate Desc
		
	END
