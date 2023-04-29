// Copyright (c) 2017 Benjamin Moir. All rights reserved.
// This work is licensed under the terms of the MIT license.  
// To obtain a copy, visit <https://opensource.org/licenses/MIT>.

class ArrayI8 { Array<int8> Values; uint Size() { return Values.Size(); } void Copy(ArrayI8 other) { Values.Copy(other.Values); } void Move(ArrayI8 other) { Values.Move(other.Values); }
	int Find(int item) { return Values.Find(item); } int Push(int item) { return Values.Push(item); } bool Pop() { return Values.Pop(); }
	void Delete(uint index, int n = 1) { Values.Delete(index, n); } void Insert(uint index, int item) { Values.Insert(index, item); } void ShrinkToFit() { Values.ShrinkToFit(); }
	void Grow(uint amount) { Values.Grow(amount); } void Resize(uint amount) { Values.Resize(amount); } int Reserve(uint amount) { return Values.Reserve(amount); }
	int Max() { return Values.Max(); } void Clear() { Values.Clear(); } }
class ArrayI16 { Array<int16> Values; uint Size() { return Values.Size(); } void Copy(ArrayI16 other) { Values.Copy(other.Values); } void Move(ArrayI16 other) { Values.Move(other.Values); }
	int Find(int item) { return Values.Find(item); } int Push(int item) { return Values.Push(item); } bool Pop() { return Values.Pop(); }
	void Delete(uint index, int n = 1) { Values.Delete(index, n); } void Insert(uint index, int item) { Values.Insert(index, item); } void ShrinkToFit() { Values.ShrinkToFit(); }
	void Grow(uint amount) { Values.Grow(amount); } void Resize(uint amount) { Values.Resize(amount); } int Reserve(uint amount) { return Values.Reserve(amount); }
	int Max() { return Values.Max(); } void Clear() { Values.Clear(); } }
class ArrayI32 { Array<int> Values; uint Size() { return Values.Size(); } void Copy(ArrayI32 other) { Values.Copy(other.Values); } void Move(ArrayI32 other) { Values.Move(other.Values); }
	int Find(int item) { return Values.Find(item); } int Push(int item) { return Values.Push(item); } bool Pop() { return Values.Pop(); }
	void Delete(uint index, int n = 1) { Values.Delete(index, n); } void Insert(uint index, int item) { Values.Insert(index, item); } void ShrinkToFit() { Values.ShrinkToFit(); }
	void Grow(uint amount) { Values.Grow(amount); } void Resize(uint amount) { Values.Resize(amount); } int Reserve(uint amount) { return Values.Reserve(amount); }
	int Max() { return Values.Max(); } void Clear() { Values.Clear(); } }
class ArrayF32 { Array<float> Values; uint Size() { return Values.Size(); } void Copy(ArrayF32 other) { Values.Copy(other.Values); } void Move(ArrayF32 other) { Values.Move(other.Values); }
	int Find(float item) { return Values.Find(item); } int Push(float item) { return Values.Push(item); } bool Pop() { return Values.Pop(); }
	void Delete(uint index, int n = 1) { Values.Delete(index, n); } void Insert(uint index, float item) { Values.Insert(index, item); } void ShrinkToFit() { Values.ShrinkToFit(); }
	void Grow(uint amount) { Values.Grow(amount); } void Resize(uint amount) { Values.Resize(amount); } int Reserve(uint amount) { return Values.Reserve(amount); }
	int Max() { return Values.Max(); } void Clear() { Values.Clear(); } }
class ArrayF64 { Array<double> Values; uint Size() { return Values.Size(); } void Copy(ArrayF64 other) { Values.Copy(other.Values); } void Move(ArrayF64 other) { Values.Move(other.Values); }
	int Find(double item) { return Values.Find(item); } int Push(double item) { return Values.Push(item); } bool Pop() { return Values.Pop(); }
	void Delete(uint index, int n = 1) { Values.Delete(index, n); } void Insert(uint index, double item) { Values.Insert(index, item); } void ShrinkToFit() { Values.ShrinkToFit(); }
	void Grow(uint amount) { Values.Grow(amount); } void Resize(uint amount) { Values.Resize(amount); } int Reserve(uint amount) { return Values.Reserve(amount); }
	int Max() { return Values.Max(); } void Clear() { Values.Clear(); } }
class ArrayStr { Array<string> Values; uint Size() { return Values.Size(); } void Copy(ArrayStr other) { Values.Copy(other.Values); } void Move(ArrayStr other) { Values.Move(other.Values); }
	int Find(string item) { return Values.Find(item); } int Push(string item) { return Values.Push(item); } bool Pop() { return Values.Pop(); }
	void Delete(uint index, int n = 1) { Values.Delete(index, n); } void Insert(uint index, string item) { Values.Insert(index, item); } void ShrinkToFit() { Values.ShrinkToFit(); }
	void Grow(uint amount) { Values.Grow(amount); } void Resize(uint amount) { Values.Resize(amount); } int Reserve(uint amount) { return Values.Reserve(amount); }
	int Max() { return Values.Max(); } void Clear() { Values.Clear(); } }
class ArrayPtr { Array<voidptr> Values; uint Size() { return Values.Size(); } void Copy(ArrayPtr other) { Values.Copy(other.Values); }
	void Move(ArrayPtr other) { Values.Move(other.Values); } int Find(voidptr item) { return Values.Find(item); } int Push(voidptr item) { return Values.Push(item); }
	bool Pop() { return Values.Pop(); } void Delete(uint index, int n = 1) { Values.Delete(index, n); } void Insert(uint index, voidptr item) { Values.Insert(index, item); }
	void ShrinkToFit() { Values.ShrinkToFit(); } void Grow(uint amount) { Values.Grow(amount); } void Resize(uint amount) { Values.Resize(amount); }
	int Reserve(uint amount) { return Values.Reserve(amount); } int Max() { return Values.Max(); } void Clear() { Values.Clear(); } }
enum ESeekOrigin { SEEK_Begin, SEEK_Current, SEEK_End, }
class Stream { int m_Position;
    virtual bool CanRead() { return false; }
    virtual bool CanWrite() { return false; }
    virtual bool CanSeek() { return true; }
    virtual int Length() { return 0; }
    virtual int Position() { return m_Position; }
    virtual int Read() { return -1; }
    virtual int Peek() { return -1; }
    virtual void Write(int c) {}
    virtual bool EOF() { return Position() >= Length(); }
    virtual int Seek(int offset, ESeekOrigin origin) {
        switch (origin) { case SEEK_Begin: m_Position = offset; break; case SEEK_Current: m_Position += offset; break; case SEEK_End: m_Position = Length() + offset; break; }
        if (m_Position > Length()) { m_Position = Length(); } if (m_Position < 0) { m_Position = 0; } return m_Position; } }
class StringStream : Stream { string m_Data;
    override bool CanRead() { return true; }
    override bool CanWrite() { return false; }
    override int Length() { return m_Data.Length(); }
    override int Read() { if (EOF()) return -1; int c = m_Data.ByteAt(Position()) & 255; Seek(1, SEEK_Current); return c; }
    override int Peek() { int pos = Position(); int c = Read(); Seek(pos, SEEK_Begin); return c; }
    static StringStream Create(string data) { let ss = new("StringStream"); ss.m_Data = data; return ss; } }
class LumpStream : StringStream { static LumpStream Create(int lumpID) { let ss = new("LumpStream"); ss.m_Data = Wads.ReadLump(lumpID); return ss; } }
class BinaryReader { Stream m_BaseStream;
    Stream GetBaseStream() { return m_BaseStream; }
    private int Read() { return m_BaseStream.Read(); }
    private int Peek() { return m_BaseStream.Peek(); }
    int ReadByte() { return Read(); }
    int ReadUInt16() { return (Read() << 0) | (Read() << 8); }
	int ReadInt16() { int i = ReadUInt16(); if (i > 32767) return i|0xFFFF0000; return i; }
    int ReadInt32() { return (Read() <<  0) | (Read() <<  8) | (Read() << 16) | (Read() << 24); }
    int ReadInt64() { return (Read() <<  0) | (Read() <<  8) | (Read() << 16) | (Read() << 24) | (Read() << 32) | (Read() << 40) | (Read() << 48) | (Read() << 56); }
    ArrayI8 ReadBytes(int count) { let arr = new("ArrayI8"); for(int i = 0; i < count; i++) { arr.Push(Read()); } return arr; }
    string ReadString(int length = -1) { string result = ""; if (length > 0) { for(int i = 0; i < length; i++) { result.AppendFormat("%c", Read()); } }
        else { while (true) { int c = Read(); if (c == 0) { break; } result.AppendFormat("%c", c); } } return result; }
    float ReadFloat32() { return 0.0; }
    double ReadFloat64() { return 0.0; }
    static BinaryReader Create(Stream input) { let br = new("BinaryReader"); br.m_BaseStream = input; return br; } }
