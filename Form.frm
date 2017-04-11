VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Begin VB.Form Form1 
   Caption         =   "dsiEMVX Tester"
   ClientHeight    =   8850
   ClientLeft      =   225
   ClientTop       =   855
   ClientWidth     =   12510
   LinkTopic       =   "Form1"
   ScaleHeight     =   8850
   ScaleWidth      =   12510
   StartUpPosition =   3  'Windows Default
   Begin MSComDlg.CommonDialog CommonDialog1 
      Left            =   7800
      Top             =   8280
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin VB.Timer Timer1 
      Left            =   8400
      Top             =   8280
   End
   Begin VB.CommandButton cmdSubmitRequest 
      Caption         =   "Submit Request"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   615
      Left            =   9120
      TabIndex        =   10
      Top             =   8160
      Width           =   3255
   End
   Begin VB.TextBox txtResponse 
      Height          =   5895
      Left            =   6360
      MultiLine       =   -1  'True
      TabIndex        =   9
      Top             =   2040
      Width           =   6015
   End
   Begin VB.TextBox txtRequest 
      Height          =   5895
      Left            =   120
      MultiLine       =   -1  'True
      TabIndex        =   8
      Top             =   2040
      Width           =   6015
   End
   Begin VB.Frame Frame1 
      Height          =   1695
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   12255
      Begin VB.TextBox txtComPort 
         Height          =   325
         Left            =   3480
         TabIndex        =   11
         Top             =   1200
         Width           =   3250
      End
      Begin VB.ComboBox cmbSecureDevice 
         Height          =   315
         Left            =   120
         TabIndex        =   6
         Top             =   1200
         Width           =   3250
      End
      Begin VB.ComboBox cmbMerchantID 
         Height          =   315
         Left            =   3480
         TabIndex        =   4
         Top             =   480
         Width           =   3250
      End
      Begin VB.TextBox txtNETePayHostList 
         Height          =   325
         Left            =   120
         TabIndex        =   2
         Top             =   480
         Width           =   3250
      End
      Begin VB.Label Label1 
         Caption         =   "Com Port"
         Height          =   330
         Index           =   7
         Left            =   3480
         TabIndex        =   7
         Top             =   960
         Width           =   3255
      End
      Begin VB.Label Label1 
         Caption         =   "Secure Device"
         Height          =   330
         Index           =   5
         Left            =   120
         TabIndex        =   5
         Top             =   960
         Width           =   3255
      End
      Begin VB.Label Label1 
         Caption         =   "Merchant ID"
         Height          =   330
         Index           =   4
         Left            =   3480
         TabIndex        =   3
         Top             =   240
         Width           =   3255
      End
      Begin VB.Label Label1 
         Caption         =   "NETePay Host List"
         Height          =   330
         Index           =   0
         Left            =   120
         TabIndex        =   1
         Top             =   240
         Width           =   3255
      End
   End
   Begin VB.Menu File 
      Caption         =   "File"
      Begin VB.Menu Open 
         Caption         =   "Open..."
      End
      Begin VB.Menu Exit 
         Caption         =   "Exit"
      End
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Dim merchantIDArray
Dim secureDeviceArray
Dim dsiEMVX


Private Sub Form_Initialize()

    merchantIDArray = Array( _
        "337234005")
        
    secureDeviceArray = Array( _
        "EMV_IPP320_MERCURY" _
        , "EMV_VX805_MERCURY" _
        , "EMV_ISC250_MERCURY")
           
End Sub


Private Sub Form_Load()
    Me.SetupForm
    Set dsiEMVX = New DSIEMVXLib.dsiEMVX
End Sub

Private Sub Open_Click()
    Me.LoadXMLRequest
End Sub

Private Sub Exit_Click()
    Unload Me
End Sub


Private Sub cmbSecureDevice_Click()
    Me.UpdateRequest
End Sub

Private Sub cmbSecureDevice_Change()
    Me.UpdateRequest
End Sub


Private Sub cmbMerchantID_Click()
    Me.UpdateRequest
End Sub

Private Sub cmbMerchantID_Change()
    Me.UpdateRequest
End Sub

Private Sub txtComPort_Change()
    Me.UpdateRequest
End Sub


Private Sub cmdSubmitRequest_Click()
    Me.txtResponse.Text = Me.ProcessRequest(Me.txtRequest.Text)
End Sub


Public Sub SetupForm()
    Me.txtNETePayHostList.Text = "127.0.0.1"
    Me.txtComPort.Text = "9"
    Me.cmbMerchantID.Clear
    
    For Each merchantID In merchantIDArray
        Me.cmbMerchantID.AddItem merchantID
    Next merchantID
    
    Me.cmbMerchantID.ListIndex = 0
    
    Me.cmbSecureDevice.Clear
    
    For Each secureDevice In secureDeviceArray
        Me.cmbSecureDevice.AddItem secureDevice
    Next secureDevice
    
    Me.cmbSecureDevice.ListIndex = 0
    
End Sub


Public Sub LoadXMLRequest()
    Me.CommonDialog1.Filter = "XML (*.xml) | *.xml"
    Me.CommonDialog1.InitDir = App.Path + "\Samples"
    Me.CommonDialog1.ShowOpen
    
    If Me.CommonDialog1.FileName = "" Then
        ' User canceled.
    Else
        ' The FileName property contains the selected file name.
        Dim doc As New MSXML2.DOMDocument
        doc.Load (Me.CommonDialog1.FileName)
        Me.txtRequest.Text = doc.xml
        Me.txtResponse.Text = ""
        Me.UpdateRequest
    End If
End Sub

Public Sub UpdateRequest()

    If Me.txtRequest.Text <> "" Then
        Dim doc As New MSXML2.DOMDocument
        doc.loadXML (Me.txtRequest.Text)
        
        If doc.getElementsByTagName("MerchantID").length > 0 Then
            Dim merchantFromComboBox As String
            merchantFromComboBox = Me.cmbMerchantID.Text
        
            If InStr(1, merchantFromComboBox, " ") > 0 Then
                merchantFromComboBox = Mid(merchantFromComboBox, 1, InStr(1, merchantFromComboBox, " ") - 1)
            End If
            
            doc.getElementsByTagName("MerchantID").Item(0).Text = merchantFromComboBox
        End If
        
        If doc.getElementsByTagName("SecureDevice").length > 0 Then
            doc.getElementsByTagName("SecureDevice").Item(0).Text = Me.cmbSecureDevice.Text
        End If
        
        If doc.getElementsByTagName("ComPort").length > 0 Then
            doc.getElementsByTagName("ComPort").Item(0).Text = Me.txtComPort.Text
        End If
        
        If doc.getElementsByTagName("HostOrIP").length > 0 Then
            doc.getElementsByTagName("HostOrIP").Item(0).Text = Me.txtNETePayHostList.Text
        End If
        
        Me.txtRequest.Text = doc.xml

    End If

End Sub

Public Function ProcessRequest(ByVal request As String) As String
   
    Dim status As String
    Dim response As String
    response = dsiEMVX.ProcessTransaction(request)

    ProcessRequest = response
    
End Function

Private Sub txtNETePayHostList_Change()
    UpdateRequest
End Sub
