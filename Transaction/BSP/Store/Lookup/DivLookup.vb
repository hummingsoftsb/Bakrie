﻿Imports Store_PPT
Imports Store_BOL
Imports Common_BOL
Imports Common_PPT
Imports System.Data.SqlClient

Public Class DivLookup

    Public psDIV As String = String.Empty
    Public psDIVID As String = String.Empty
    Public psDIVName As String = String.Empty
    Public psSIVBlockIDValue As String = String.Empty

    Private Sub btnClose_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnClose.Click

        ClearAfterSearch()
        DialogResult = Windows.Forms.DialogResult.Cancel
        Me.Close()

    End Sub

    Private Sub ClearAfterSearch()

        txtDIVSearch.Text = String.Empty
        txtDivNameSearch.Text = String.Empty

    End Sub

    Private Sub DivLookup_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load

        SetUICulture(GlobalPPT.strLang)
        BindDIV(txtDIVSearch.Text)

    End Sub

    Sub SetUICulture(ByVal culture As String)

        ' get a reference to the ResourceManager for this form
        Dim rm As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(DivLookup))
        Try
            'set the culture as per the selection and 
            'load the appropriate strings for button, label, etc.
            System.Threading.Thread.CurrentThread.CurrentUICulture = New System.Globalization.CultureInfo(culture)

            lbldivSearch.Text = rm.GetString("lbldivSearch.Text")
            lblDivNameSearch.Text = rm.GetString("lblDivNameSearch.Text")
            panDIVLookUp.CaptionText = rm.GetString("panDIVLookUp.CaptionText")

            dgDIV.Columns("dgclDivID").HeaderText = rm.GetString("dgDIV.Columns(dgclDivID).HeaderText")
            dgDIV.Columns("dgclDiv").HeaderText = rm.GetString("dgDIV.Columns(dgclDiv).HeaderText")
            dgDIV.Columns("dgclDivName").HeaderText = rm.GetString("dgDIV.Columns(dgclDivName).HeaderText")
            lblsearchDiv.Text = rm.GetString("lblsearchDiv.Text")
        Catch
            'display a message if the culture is not supported
            'try passing bn (Bengali) for testing
            MessageBox.Show("Locale '" & culture & "' isn't supported", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
        End Try

    End Sub

    Public Sub BindDIV(ByVal psSIVBlockID)

        Dim objDiv As New StoreIssueVoucherPPT
        Dim ds As New DataSet
        psSIVBlockIDValue = psSIVBlockID
        objDiv.BlockID = psSIVBlockID
        objDiv.Div = txtDIVSearch.Text.Trim()
        objDiv.DivName = txtDivNameSearch.Text.Trim()

        ds = StoreIssueVoucherBOL.GetDIV(objDiv, "NO")
        If (ds.Tables(0).Rows.Count <= 0) Then
            lblNoRecord.Visible = True
            dgDIV.AutoGenerateColumns = False
            dgDIV.DataSource = ds.Tables(0)
        Else
            lblNoRecord.Visible = False
            dgDIV.AutoGenerateColumns = False
            dgDIV.DataSource = ds.Tables(0)
        End If

    End Sub

    Private Sub btnDIVSearch_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnDIVSearch.Click
        Me.Cursor = Cursors.WaitCursor
        BindDIV(psSIVBlockIDValue)
        ''Dim objDivPPt As New StoreIssueVoucherPPT
        ''Dim ds As New DataSet
        ''objDivPPt.Div = txtDIVSearch.Text.Trim()
        ''objDivPPt.DivName = txtDivNameSearch.Text.Trim()
        ''ds = StoreIssueVoucherBOL.GetDIV(objDivPPt, "NO")
        ''If (ds.Tables(0).Rows.Count <= 0) Then
        ''    lblNoRecord.Visible = True
        ''    dgDIV.AutoGenerateColumns = False
        ''    dgDIV.DataSource = ds.Tables(0)
        ''Else
        ''    lblNoRecord.Visible = False
        ''    dgDIV.AutoGenerateColumns = False
        ''    dgDIV.DataSource = ds.Tables(0)
        ''End If
        'Dim objDiv As New StoreIssueVoucherPPT
        'Dim ds As New DataSet
        'ds = StoreIssueVoucherBOL.GetDIV(objDiv)
        'dgDIV.DataSource = ds.Tables(0)
        Me.Cursor = Cursors.Arrow
    End Sub
    Private Sub dgDIV_CellDoubleClick(ByVal sender As System.Object, ByVal e As System.Windows.Forms.DataGridViewCellEventArgs) Handles dgDIV.CellDoubleClick

        Grid_Click()

    End Sub

    Private Sub Grid_Click()

        If dgDIV.RowCount <> 0 Then
            Dim objDiv As New StoreIssueVoucherPPT
            psDIVID = dgDIV.CurrentRow.Cells("dgclDivID").Value.ToString()
            psDIV = dgDIV.CurrentRow.Cells("dgclDiv").Value.ToString()
            psDIVName = dgDIV.CurrentRow.Cells("dgclDivName").Value.ToString()
            DialogResult = Windows.Forms.DialogResult.OK
            Me.Close()
        Else
            MessageBox.Show("There is no record to select")
        End If

    End Sub

    Private Sub DivLookup_KeyDown(ByVal sender As System.Object, ByVal e As System.Windows.Forms.KeyEventArgs) Handles MyBase.KeyDown

        If e.KeyCode = Keys.Enter Then
            SendKeys.Send("{TAB}")
        End If

    End Sub

    Private Sub dgDIV_KeyDown(ByVal sender As System.Object, ByVal e As System.Windows.Forms.KeyEventArgs)

        If e.KeyCode = Keys.Return Then
            Grid_Click()
            e.Handled = True
        End If
        If e.KeyValue = 40 Then
            GlobalBOL.KeyDownEvent(dgDIV, e)
        End If
        'If e.KeyValue = 38 Then
        '    GlobalBOL.KeyDownEvent(dgDIV, e)
        'End If

    End Sub

    Private Sub dgDIV_KeyUp(ByVal sender As Object, ByVal e As System.Windows.Forms.KeyEventArgs)

        If e.KeyValue = 38 Then
            GlobalBOL.KeyUpEvent(dgDIV, e)
        End If

    End Sub

    Private Sub dgDIV_CellContentClick(ByVal sender As System.Object, ByVal e As System.Windows.Forms.DataGridViewCellEventArgs) Handles dgDIV.CellContentClick

    End Sub
End Class