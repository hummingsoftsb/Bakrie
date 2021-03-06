SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Checkroll].[CRRekapitulasiAdvancePaymentReport]

	@EstateID nvarchar(50),
	@ActiveMonthYearID nvarchar(50)


AS

SELECT 

G_M.GangName,
SUM(C_APD.Amount) AS SumAmount,
SUM(C_APD.DedJamsostek) AS SumJamsostek,
SUM(C_APD.PaidAmount) AS SumPaidAmount,
ISNULL(SUM(C_APD.DedOther ),0) AS Koperasi

FROM Checkroll.AdvancePaymentDet AS C_APD 
	inner join Checkroll .AdvancePayment c_ap ON c_ap .AdvancePaymentID = C_APD .AdvancePaymentID 
    INNER JOIN Checkroll.Salary as C_SAL on C_SAL.ActiveMonthYearID =@ActiveMonthYearID and C_APD.EmpID = C_SAL.EmpID  
 	INNER JOIN Checkroll .GangMaster AS G_M ON G_M.GangMasterID =C_SAL.GangMasterID
Where C_APD .EstateID =@EstateID 
	  AND c_ap .ActiveMonthYearID =@ActiveMonthYearID 


GROUP BY GangName
