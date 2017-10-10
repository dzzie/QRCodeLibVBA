VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "AlphanumericEncoder"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'----------------------------------------------------------------------------------------
' �p�������[�h�G���R�[�_�[
'----------------------------------------------------------------------------------------
Option Explicit

Implements IQRCodeEncoder

Private m_data()        As Long
Private m_charCounter   As Long
Private m_bitCounter    As Long

'----------------------------------------------------------------------------------------
' (�T�v)
'  �r�b�g�����擾���܂��B
'----------------------------------------------------------------------------------------
Private Property Get IQRCodeEncoder_BitCount() As Long
    
    IQRCodeEncoder_BitCount = m_bitCounter

End Property

'----------------------------------------------------------------------------------------
' (�T�v)
'  ���������擾���܂��B
'----------------------------------------------------------------------------------------
Private Property Get IQRCodeEncoder_CharCount() As Long
    
    IQRCodeEncoder_CharCount = m_charCounter

End Property

'----------------------------------------------------------------------------------------
' (�T�v)
'  ���������[�h��\�� EncodingMode �񋓑̂̒l���擾���܂��B
'----------------------------------------------------------------------------------------
Private Property Get IQRCodeEncoder_EncodingMode() As EncodingMode
    
    IQRCodeEncoder_EncodingMode = EncodingMode.ALPHA_NUMERIC

End Property

'----------------------------------------------------------------------------------------
' (�T�v)
'  ���[�h�w���q���擾���܂��B
'----------------------------------------------------------------------------------------
Private Property Get IQRCodeEncoder_ModeIndicator() As Long
    
    IQRCodeEncoder_ModeIndicator = ModeIndicator.ALPAHNUMERIC_VALUE

End Property

'----------------------------------------------------------------------------------------
' (�T�v)
'  ���݂̃��[�h�V�[�P���X�ɕ�����ǉ����A�ǉ��ɗv�����r�b�g����Ԃ��܂��B
'----------------------------------------------------------------------------------------
Private Function IQRCodeEncoder_Append(ByVal c As String) As Long

#If [DEBUG] Then
    Debug.Assert Len(c) = 1
    Debug.Assert IQRCodeEncoder_IsInSubset(c)
#End If

    Dim wd As Long
    wd = ConvertCharCode(c)
    
    Dim ret As Long
    
    If m_charCounter Mod 2 = 0 Then
        If m_charCounter = 0 Then
            ReDim m_data(0)
        Else
            ReDim Preserve m_data(UBound(m_data) + 1)
        End If
        
        m_data(UBound(m_data)) = wd
        ret = 6
    Else
        m_data(UBound(m_data)) = m_data(UBound(m_data)) * 45
        m_data(UBound(m_data)) = m_data(UBound(m_data)) + wd
        ret = 5
    End If

    m_charCounter = m_charCounter + 1
    m_bitCounter = m_bitCounter + ret
    
    IQRCodeEncoder_Append = ret

End Function

'----------------------------------------------------------------------------------------
' (�T�v)
'  �w��̕������G���R�[�h�����R�[�h��̃r�b�g����Ԃ��܂��B
'----------------------------------------------------------------------------------------
Private Function IQRCodeEncoder_GetCodewordBitLength(ByVal c As String) As Long

#If [DEBUG] Then
    Debug.Assert Len(c) = 1
    Debug.Assert IQRCodeEncoder_IsInSubset(c)
#End If

    If m_charCounter Mod 2 = 0 Then
        IQRCodeEncoder_GetCodewordBitLength = 6
    Else
        IQRCodeEncoder_GetCodewordBitLength = 5
    End If
    
End Function

'----------------------------------------------------------------------------------------
' (�T�v)
'  �G���R�[�h���ꂽ�o�C�g�f�[�^��Ԃ��܂��B
'----------------------------------------------------------------------------------------
Private Function IQRCodeEncoder_GetBytes() As Byte()

    Dim bs As BitSequence
    Set bs = New BitSequence
    
    Dim bitLength As Long
    bitLength = 11
    
    Dim i As Long
    
    For i = 0 To UBound(m_data) - 1
        Call bs.Append(m_data(i), bitLength)
    Next
    
    If m_charCounter Mod 2 = 0 Then
        bitLength = 11
    Else
        bitLength = 6
    End If
    
    Call bs.Append(m_data(UBound(m_data)), bitLength)
            
    IQRCodeEncoder_GetBytes = bs.GetBytes()
    
End Function

'----------------------------------------------------------------------------------------
' (�T�v)
'  �w��̕��������������[�h�ɓK������ꍇ�� True ��Ԃ��܂��B
'----------------------------------------------------------------------------------------
Private Function IQRCodeEncoder_IsInSubset(ByVal c As String) As Boolean

#If [DEBUG] Then
    Debug.Assert Len(c) = 1
#End If

    Dim ret As Boolean
    
    Select Case Asc(c)
        ' A - Z
        Case 65 To 90
            ret = True
        ' 0 - 9
        Case 48 To 57
            ret = True
        ' (Space)
        Case 32
            ret = True
        ' $ %
        Case 36, 37
            ret = True
        ' * +
        Case 42, 43
            ret = True
        ' - .
        Case 45, 46
            ret = True
        ' /
        Case 47
            ret = True
        ' :
        Case 58
            ret = True
    
        Case Else
            ret = False
            
    End Select

    IQRCodeEncoder_IsInSubset = ret

End Function

'----------------------------------------------------------------------------------------
' (�T�v)
'  �w��̕��������������[�h�̔r���I�����W���̏ꍇ�� True ��Ԃ��܂��B
'----------------------------------------------------------------------------------------
Private Function IQRCodeEncoder_IsInExclusiveSubset(ByVal c As String) As Boolean

#If [DEBUG] Then
    Debug.Assert Len(c) = 1
#End If

    Dim ret As Boolean
    
    Select Case Asc(c)
        ' A - Z
        Case 65 To 90
            ret = True
        ' (Space)
        Case 32
            ret = True
        ' $ %
        Case 36, 37
            ret = True
        ' * +
        Case 42, 43
            ret = True
        ' - .
        Case 45, 46
            ret = True
        ' /
        Case 47
            ret = True
        ' :
        Case 58
            ret = True
    
        Case Else
            ret = False
        
    End Select
    
    IQRCodeEncoder_IsInExclusiveSubset = ret

End Function

'----------------------------------------------------------------------------------------
' (�T�v)
'  �w�肵�������̉p�������[�h�ɂ����镶���R�[�h��Ԃ��܂��B�Y�����镶���R�[�h�����݂��Ȃ�
'  �ꍇ�� -1 ��Ԃ��܂��B
'----------------------------------------------------------------------------------------
Private Function ConvertCharCode(ByVal c As String) As Long

#If [DEBUG] Then
    Debug.Assert Len(c) = 1
#End If

    Dim code As Long
    code = Asc(c)

    Select Case code
        ' A - Z
        Case 65 To 90
            ConvertCharCode = code - 55
        ' 0 - 9
        Case 48 To 57
            ConvertCharCode = code - 48
        ' (Space)
        Case 32
            ConvertCharCode = 36
        ' $ %
        Case 36, 37
            ConvertCharCode = code + 1
        ' * +
        Case 42, 43
            ConvertCharCode = code - 3
        ' - .
        Case 45, 46
            ConvertCharCode = code - 4
        ' /
        Case 47
            ConvertCharCode = 43
        ' :
        Case 58
            ConvertCharCode = 44
    
        Case Else
            ConvertCharCode = -1
            
    End Select

End Function
