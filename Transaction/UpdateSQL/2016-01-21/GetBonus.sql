/****** Object:  StoredProcedure [Checkroll].[SalaryEmployee]    Script Date: 21/1/2016 10:10:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [Checkroll].[BonusEmployee]
	@ActiveMonthYearID nvarchar(50),
	@EstateID nvarchar(50)
AS
BEGIN

Select a.EmpCode,a.EmpName,a.EmpID,a.Category,a.BankID,a.OEEmpLocation,
b.Bruto,b.BerasNatura,b.DedCooper as SPSI,b.DedOthers as SPSB from Checkroll.CREmployee a
inner join Checkroll.Bonus b on a.EmpID = b.EmpID
WHERE        b.ActiveMonthYearID = @ActiveMonthYearID
and b.EstateID = @EstateID
ORDER BY a.EmpCode ASC

END

