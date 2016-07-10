/***************************************************************************
* Copyright (c) 2000-2004, Future Systems, Inc. / Seoul, Republic of Korea *
* All Rights Reserved.                                                     *
*                                                                          *
* This document contains proprietary and confidential information.  No     *
* parts of this document or the computer program it embodies may be in     *
* any way copied, duplicated, reproduced, translated into a different      *
* programming language, or distributed to any person, company, or          *
* corporation without the prior written consent of Future Systems, Inc.    *
*                              Hyo Sun Hwang                               *
*                372-2 YangJae B/D 6th Floor, Seoul, Korea                 *
*                           +82-2-578-0581 (552)                           *
***************************************************************************/

/*--------------------- [ Version/Command in detais] ---------------------*\
Description : aes.c
			(C-source file) Block Cipher AES - core function

C0000 : Created by Hyo Sun Hwang (hyosun@future.co.kr) 2000/12/31

C0001 : Modified by Hyo Sun Hwang (hyosun@future.co.kr) 2000/00/00

\*------------------------------------------------------------------------*/

/*************** Header files *********************************************/
#include "aes.h"

void	AES_Encrypt(
                    void		*CipherKey,
                    BYTE		*Data);
void	AES_Decrypt(
                    void		*CipherKey,
                    BYTE		*Data);
/*************** Assertions ***********************************************/

/*************** New Data Types *******************************************/
typedef struct {
	DWORD	k_len;
	DWORD	RK[64];
} RIJNDAEL_CIPHER_KEY;

/*************** Definitions / Macros  ************************************/
#define u1byte	BYTE
#define u4byte	DWORD
#define rotl	ROTL_DWORD
#define rotr	ROTR_DWORD
#define byte(x,n)	((u1byte)((x) >> (8 * n)))

#define LARGE_TABLES

#define ff_mult(a,b)	(a && b ? pow_tab[(log_tab[a] + log_tab[b]) % 255] : 0)

#ifdef LARGE_TABLES
	#define ls_box(x)				 \
		( fl_tab[0][byte(x, 0)] ^	 \
		  fl_tab[1][byte(x, 1)] ^	 \
		  fl_tab[2][byte(x, 2)] ^	 \
		  fl_tab[3][byte(x, 3)] )
#else
	#define ls_box(x)							 \
		((u4byte)sbx_tab[byte(x, 0)] <<  0) ^	 \
		((u4byte)sbx_tab[byte(x, 1)] <<  8) ^	 \
		((u4byte)sbx_tab[byte(x, 2)] << 16) ^	 \
		((u4byte)sbx_tab[byte(x, 3)] << 24)
#endif

/*************** Global Variables *****************************************/
static u1byte	log_tab[256];
static u1byte	pow_tab[256];
static u1byte	sbx_tab[256];
static u1byte	isb_tab[256];
static u4byte	rco_tab[ 10];
static u4byte	ft_tab[4][256];
static u4byte	it_tab[4][256];

#ifdef	LARGE_TABLES
  static u4byte  fl_tab[4][256];
  static u4byte  il_tab[4][256];
#endif

static u4byte	tab_gen = 0;


/*************** Prototypes ***********************************************/
static void gen_tabs(void)
{
	u4byte	i, t;
	u1byte	p, q;

	/* log and power tables for GF(2**8) finite field with	*/
	/* 0x11b as modular polynomial - the simplest prmitive	*/
	/* root is 0x11, used here to generate the tables		*/

	log_tab[7] = 0;
	for(i = 0,p = 1; i < 256; ++i)
	{
		pow_tab[i] = (BYTE)p;
		log_tab[p] = (BYTE)i;

		p = (BYTE)(p ^ (p << 1) ^ (p & 0x80 ? 0x01b : 0));
	}

	log_tab[1] = 0;
	p = 1;

	for(i = 0; i < 10; ++i)
	{
		rco_tab[i] = p; 

		p = (BYTE)((p << 1) ^ (p & 0x80 ? 0x1b : 0));
	}

	/* note that the affine byte transformation matrix in	*/
	/* rijndael specification is in big endian format with	*/
	/* bit 0 as the most significant bit. In the remainder	*/
	/* of the specification the bits are numbered from the	*/
	/* least significant end of a byte. 					*/

	for(i = 0; i < 256; ++i)
	{	
		p = (BYTE)(i ? pow_tab[255 - log_tab[i]] : 0);
		q = p;
		q = (BYTE)((q >> 7) | (q << 1));
		p ^= q;
		q = (BYTE)((q >> 7) | (q << 1));
		p ^= q;
		q = (BYTE)((q >> 7) | (q << 1));
		p ^= q;
		q = (BYTE)((q >> 7) | (q << 1));
		p ^= q ^ 0x63;
		sbx_tab[i] = (u1byte)p;
		isb_tab[p] = (u1byte)i;
	}

	for(i = 0; i < 256; ++i)
	{
		p = sbx_tab[i]; 

#ifdef	LARGE_TABLES
		t = p;
		fl_tab[0][i] = t;
		fl_tab[1][i] = rotl(t,  8);
		fl_tab[2][i] = rotl(t, 16);
		fl_tab[3][i] = rotl(t, 24);
#endif
		t = ((u4byte)ff_mult(2, p)) |
			((u4byte)p <<  8) |
			((u4byte)p << 16) |
			((u4byte)ff_mult(3, p) << 24);
		
		ft_tab[0][i] = t;
		ft_tab[1][i] = rotl(t,	8);
		ft_tab[2][i] = rotl(t, 16);
		ft_tab[3][i] = rotl(t, 24);

		p = isb_tab[i]; 

#ifdef	LARGE_TABLES
		t = p; il_tab[0][i] = t; 
		il_tab[1][i] = rotl(t,	8); 
		il_tab[2][i] = rotl(t, 16); 
		il_tab[3][i] = rotl(t, 24);
#endif 
		t = ((u4byte)ff_mult(14, p)) |
			((u4byte)ff_mult( 9, p) <<	8) |
			((u4byte)ff_mult(13, p) << 16) |
			((u4byte)ff_mult(11, p) << 24);
		
		it_tab[0][i] = t; 
		it_tab[1][i] = rotl(t,	8); 
		it_tab[2][i] = rotl(t, 16); 
		it_tab[3][i] = rotl(t, 24); 
	}

	tab_gen = 1;
};

#define star_x(x) (((x) & 0x7f7f7f7f) << 1) ^ ((((x) & 0x80808080) >> 7) * 0x1b)

#define imix_col(y,x)		\
	 u	= star_x(x);		\
	 v	= star_x(u);		\
	 w	= star_x(v);		\
	 t	= w ^ (x);			\
	(y) = u ^ v ^ w;		\
	(y) ^= rotr(u ^ t,  8) ^ \
		  rotr(v ^ t, 16) ^ \
		  rotr(t,24)

/**************************************************************************
*
*	Function Description ...
*	
*	Return values:
*		- CTR_SUCCESS						�Լ��� ���������� �����.
*		...
*/
static void RIJNDAEL_KeySchedule(
		BYTE		*UserKey,		//	����� ���Ű �Է�
		DWORD		k_len,			//	����� ���Ű�� DWORD ��
		DWORD		*e_key)			//	��ȣ�� Round Key ����/���
{
	u4byte	i, t;

	////
	if(!tab_gen)
		gen_tabs();

	LITTLE_B2D(&(UserKey[ 0]), e_key[0]);
	LITTLE_B2D(&(UserKey[ 4]), e_key[1]);
	LITTLE_B2D(&(UserKey[ 8]), e_key[2]);
	LITTLE_B2D(&(UserKey[12]), e_key[3]);

	switch(k_len)
	{
		case 4:
				t = e_key[3];
				for(i = 0; i < 10; ++i) {
					t = ls_box(rotr(t,  8)) ^ rco_tab[i];
					t ^= e_key[4 * i];     e_key[4 * i + 4] = t;
					t ^= e_key[4 * i + 1]; e_key[4 * i + 5] = t;
					t ^= e_key[4 * i + 2]; e_key[4 * i + 6] = t;
					t ^= e_key[4 * i + 3]; e_key[4 * i + 7] = t;
				}
				break;

		case 6:
				LITTLE_B2D(&(UserKey[16]), e_key[4]);
				LITTLE_B2D(&(UserKey[20]), e_key[5]);
				t = e_key[5];
				for(i = 0; i < 8; ++i) {
					t = ls_box(rotr(t,	8)) ^ rco_tab[i];
					t ^= e_key[6 * i];	   e_key[6 * i + 6] = t;
					t ^= e_key[6 * i + 1]; e_key[6 * i + 7] = t;
					t ^= e_key[6 * i + 2]; e_key[6 * i + 8] = t;
					t ^= e_key[6 * i + 3]; e_key[6 * i + 9] = t;
					t ^= e_key[6 * i + 4]; e_key[6 * i + 10] = t;
					t ^= e_key[6 * i + 5]; e_key[6 * i + 11] = t;
				}
//					loop6(i);
				break;

		case 8:
				LITTLE_B2D(&(UserKey[16]), e_key[4]);
				LITTLE_B2D(&(UserKey[20]), e_key[5]);
				LITTLE_B2D(&(UserKey[24]), e_key[6]);
				LITTLE_B2D(&(UserKey[28]), e_key[7]);
				t = e_key[7];
				for(i = 0; i < 7; ++i) {
					t = ls_box(rotr(t,	8)) ^ rco_tab[i];
					t ^= e_key[8 * i];	   e_key[8 * i + 8] = t;
					t ^= e_key[8 * i + 1]; e_key[8 * i + 9] = t;
					t ^= e_key[8 * i + 2]; e_key[8 * i + 10] = t;
					t ^= e_key[8 * i + 3]; e_key[8 * i + 11] = t;
					t  = e_key[8 * i + 4] ^ ls_box(t);
					e_key[8 * i + 12] = t;
					t ^= e_key[8 * i + 5]; e_key[8 * i + 13] = t;
					t ^= e_key[8 * i + 6]; e_key[8 * i + 14] = t;
					t ^= e_key[8 * i + 7]; e_key[8 * i + 15] = t;
				}
//					loop8(i);
				break;
	}
}

/*************** Function *************************************************
* 
*/
RET_VAL AES_EncKeySchedule(
		BYTE		*UserKey,		//	����� ���Ű �Է�
		DWORD		UserKeyLen,		//	����� ���Ű�� ����Ʈ ��
		AES_ALG_INFO	*AlgInfo)	//	��ȣ��/��ȣ�� Round Key ����/����
{
	RIJNDAEL_CIPHER_KEY	*RK_Struct=(RIJNDAEL_CIPHER_KEY *) AlgInfo->RoundKey;
	DWORD	*e_key=RK_Struct->RK;	//	64 DWORDs
	DWORD	k_len;

	//	UserKey�� ���̰� �������� ��� error ó��
	if( (UserKeyLen!=16) && (UserKeyLen!=24) && (UserKeyLen!=32) )
		return CTR_INVALID_USERKEYLEN;

	////
	k_len = (UserKeyLen + 3) / 4;
	RK_Struct->k_len = k_len;

	RIJNDAEL_KeySchedule(UserKey, k_len, e_key);

	return CTR_SUCCESS;
}

/*************** Function *************************************************
* 
*/
RET_VAL AES_DecKeySchedule(
		BYTE		*UserKey,		//	����� ���Ű �Է�
		DWORD		UserKeyLen,		//	����� ���Ű�� ����Ʈ ��
		AES_ALG_INFO	*AlgInfo)	//	��ȣ��/��ȣ�� Round Key ����/����
{
	RIJNDAEL_CIPHER_KEY	*RK_Struct=(RIJNDAEL_CIPHER_KEY *) AlgInfo->RoundKey;
	DWORD	*d_key=RK_Struct->RK;	//	64 DWORDs
	DWORD	k_len, t_key[64];
	u4byte	i, t, u, v, w;

	//	UserKey�� ���̰� �������� ��� error ó��
	if( (UserKeyLen!=16) && (UserKeyLen!=24) && (UserKeyLen!=32) )
		return CTR_INVALID_USERKEYLEN;

	////
	k_len = (UserKeyLen + 3) / 4;
	RK_Struct->k_len = k_len;

	RIJNDAEL_KeySchedule(UserKey, k_len, t_key);

	d_key[0] = t_key[4 * k_len + 24];
	d_key[1] = t_key[4 * k_len + 25];
	d_key[2] = t_key[4 * k_len + 26];
	d_key[3] = t_key[4 * k_len + 27];

	for( i=4; i<4*(k_len+6); i+=4) {
		imix_col(d_key[i+0], t_key[4*k_len+24-i+0]);
		imix_col(d_key[i+1], t_key[4*k_len+24-i+1]);
		imix_col(d_key[i+2], t_key[4*k_len+24-i+2]);
		imix_col(d_key[i+3], t_key[4*k_len+24-i+3]);
	}
	d_key[i+0] = t_key[4*k_len+24-i+0];
	d_key[i+1] = t_key[4*k_len+24-i+1];
	d_key[i+2] = t_key[4*k_len+24-i+2];
	d_key[i+3] = t_key[4*k_len+24-i+3];

	return CTR_SUCCESS;
}

/*
	DWORD	A, B, C, D, T0, T1, *K=AlgInfo->RoundKey;

	////
	if( UserKeyLen!=SEED_USER_KEY_LEN )
		return CTR_INVALID_USERKEYLEN;

	////
	BIG_B2D( &(UserKey[0]), A);
	BIG_B2D( &(UserKey[4]), B);
	BIG_B2D( &(UserKey[8]), C);
	BIG_B2D( &(UserKey[12]), D);

	T0 = A + C - KC0;
	T1 = B - D + KC0;
	K[0] = SEED_SL[0][(T0    )&0xFF] ^ SEED_SL[1][(T0>> 8)&0xFF]
		 ^ SEED_SL[2][(T0>>16)&0xFF] ^ SEED_SL[3][(T0>>24)&0xFF];
	K[1] = SEED_SL[0][(T1    )&0xFF] ^ SEED_SL[1][(T1>> 8)&0xFF]
		 ^ SEED_SL[2][(T1>>16)&0xFF] ^ SEED_SL[3][(T1>>24)&0xFF];;

	EncRoundKeyUpdate0(K+ 2, A, B, C, D, KC1 );
	EncRoundKeyUpdate1(K+ 4, A, B, C, D, KC2 );
	EncRoundKeyUpdate0(K+ 6, A, B, C, D, KC3 );
	EncRoundKeyUpdate1(K+ 8, A, B, C, D, KC4 );
	EncRoundKeyUpdate0(K+10, A, B, C, D, KC5 );
	EncRoundKeyUpdate1(K+12, A, B, C, D, KC6 );
	EncRoundKeyUpdate0(K+14, A, B, C, D, KC7 );
	EncRoundKeyUpdate1(K+16, A, B, C, D, KC8 );
	EncRoundKeyUpdate0(K+18, A, B, C, D, KC9 );
	EncRoundKeyUpdate1(K+20, A, B, C, D, KC10);
	EncRoundKeyUpdate0(K+22, A, B, C, D, KC11);
	EncRoundKeyUpdate1(K+24, A, B, C, D, KC12);
	EncRoundKeyUpdate0(K+26, A, B, C, D, KC13);
	EncRoundKeyUpdate1(K+28, A, B, C, D, KC14);
	EncRoundKeyUpdate0(K+30, A, B, C, D, KC15);

	//	Remove sensitive data
	A = B = C = D = T0 = T1 = 0;
	K = NULL;

	//
	return CTR_SUCCESS;
*/

/*************** Macros ***************************************************/
#define f_nround(bo, bi, k) {				\
	bo[0] = ft_tab[0][byte(bi[0],0)]		\
		  ^ ft_tab[1][byte(bi[1],1)]		\
		  ^ ft_tab[2][byte(bi[2],2)]		\
		  ^ ft_tab[3][byte(bi[3],3)] ^ k[0];\
	bo[1] = ft_tab[0][byte(bi[1],0)]		\
		  ^ ft_tab[1][byte(bi[2],1)]		\
		  ^ ft_tab[2][byte(bi[3],2)]		\
		  ^ ft_tab[3][byte(bi[0],3)] ^ k[1];\
	bo[2] = ft_tab[0][byte(bi[2],0)]		\
		  ^ ft_tab[1][byte(bi[3],1)]		\
		  ^ ft_tab[2][byte(bi[0],2)]		\
		  ^ ft_tab[3][byte(bi[1],3)] ^ k[2];\
	bo[3] = ft_tab[0][byte(bi[3],0)]		\
		  ^ ft_tab[1][byte(bi[0],1)]		\
		  ^ ft_tab[2][byte(bi[1],2)]		\
		  ^ ft_tab[3][byte(bi[2],3)] ^ k[3];\
	k += 4;									\
}

#define i_nround(bo, bi, k) {				\
	bo[0] = it_tab[0][byte(bi[0],0)]		\
		  ^ it_tab[1][byte(bi[3],1)]		\
		  ^ it_tab[2][byte(bi[2],2)]		\
		  ^ it_tab[3][byte(bi[1],3)] ^ k[0];\
	bo[1] = it_tab[0][byte(bi[1],0)]		\
		  ^ it_tab[1][byte(bi[0],1)]		\
		  ^ it_tab[2][byte(bi[3],2)]		\
		  ^ it_tab[3][byte(bi[2],3)] ^ k[1];\
	bo[2] = it_tab[0][byte(bi[2],0)]		\
		  ^ it_tab[1][byte(bi[1],1)]		\
		  ^ it_tab[2][byte(bi[0],2)]		\
		  ^ it_tab[3][byte(bi[3],3)] ^ k[2];\
	bo[3] = it_tab[0][byte(bi[3],0)]		\
		  ^ it_tab[1][byte(bi[2],1)]		\
		  ^ it_tab[2][byte(bi[1],2)]		\
		  ^ it_tab[3][byte(bi[0],3)] ^ k[3];\
	k += 4;					\
}

#ifdef LARGE_TABLES
	#define f_lround(bo, bi, k) {				\
		bo[0] = fl_tab[0][byte(bi[0],0)]		\
			  ^ fl_tab[1][byte(bi[1],1)]		\
			  ^ fl_tab[2][byte(bi[2],2)]		\
			  ^ fl_tab[3][byte(bi[3],3)] ^ k[0];\
		bo[1] = fl_tab[0][byte(bi[1],0)]		\
			  ^ fl_tab[1][byte(bi[2],1)]		\
			  ^ fl_tab[2][byte(bi[3],2)]		\
			  ^ fl_tab[3][byte(bi[0],3)] ^ k[1];\
		bo[2] = fl_tab[0][byte(bi[2],0)]		\
			  ^ fl_tab[1][byte(bi[3],1)]		\
			  ^ fl_tab[2][byte(bi[0],2)]		\
			  ^ fl_tab[3][byte(bi[1],3)] ^ k[2];\
		bo[3] = fl_tab[0][byte(bi[3],0)]		\
			  ^ fl_tab[1][byte(bi[0],1)]		\
			  ^ fl_tab[2][byte(bi[1],2)]		\
			  ^ fl_tab[3][byte(bi[2],3)] ^ k[3];\
	}

	#define i_lround(bo, bi, k) {				\
		bo[0] = il_tab[0][byte(bi[0],0)]		\
			  ^ il_tab[1][byte(bi[3],1)]		\
			  ^ il_tab[2][byte(bi[2],2)]		\
			  ^ il_tab[3][byte(bi[1],3)] ^ k[0];\
		bo[1] = il_tab[0][byte(bi[1],0)]		\
			  ^ il_tab[1][byte(bi[0],1)]		\
			  ^ il_tab[2][byte(bi[3],2)]		\
			  ^ il_tab[3][byte(bi[2],3)] ^ k[1];\
		bo[2] = il_tab[0][byte(bi[2],0)]		\
			  ^ il_tab[1][byte(bi[1],1)]		\
			  ^ il_tab[2][byte(bi[0],2)]		\
			  ^ il_tab[3][byte(bi[3],3)] ^ k[2];\
		bo[3] = il_tab[0][byte(bi[3],0)]		\
			  ^ il_tab[1][byte(bi[2],1)]		\
			  ^ il_tab[2][byte(bi[1],2)]		\
			  ^ il_tab[3][byte(bi[0],3)] ^ k[3];\
		}
#else
	#define f_rl(bo, bi, n, k)										\
		bo[n] = (u4byte)sbx_tab[byte(bi[n],0)] ^					\
			rotl(((u4byte)sbx_tab[byte(bi[(n + 1) & 3],1)]),  8) ^	\
			rotl(((u4byte)sbx_tab[byte(bi[(n + 2) & 3],2)]), 16) ^	\
			rotl(((u4byte)sbx_tab[byte(bi[(n + 3) & 3],3)]), 24) ^ *(k + n)

	#define i_rl(bo, bi, n, k)										\
		bo[n] = (u4byte)isb_tab[byte(bi[n],0)] ^					\
			rotl(((u4byte)isb_tab[byte(bi[(n + 3) & 3],1)]),  8) ^	\
			rotl(((u4byte)isb_tab[byte(bi[(n + 2) & 3],2)]), 16) ^	\
			rotl(((u4byte)isb_tab[byte(bi[(n + 1) & 3],3)]), 24) ^ *(k + n)

	#define f_lround(bo, bi, k) \
		f_rl(bo, bi, 0, k); 	\
		f_rl(bo, bi, 1, k); 	\
		f_rl(bo, bi, 2, k); 	\
		f_rl(bo, bi, 3, k)

	#define i_lround(bo, bi, k) \
		i_rl(bo, bi, 0, k); 	\
		i_rl(bo, bi, 1, k); 	\
		i_rl(bo, bi, 2, k); 	\
		i_rl(bo, bi, 3, k)
#endif

/*************** Function *************************************************
*	
*/
void	AES_Encrypt(
		void		*CipherKey,		//
		BYTE		*Data)			//
{
	RIJNDAEL_CIPHER_KEY	*RK_Struct=CipherKey;
	DWORD	*e_key=RK_Struct->RK;	//	64 DWORDs
	DWORD	k_len=RK_Struct->k_len;
	u4byte	b0[4], b1[4], *kp;

	LITTLE_B2D(&(Data[ 0]), b0[0]);
	LITTLE_B2D(&(Data[ 4]), b0[1]);
	LITTLE_B2D(&(Data[ 8]), b0[2]);
	LITTLE_B2D(&(Data[12]), b0[3]);

	//
	b0[0] ^= e_key[0];
	b0[1] ^= e_key[1];
	b0[2] ^= e_key[2];
	b0[3] ^= e_key[3];

	kp = e_key + 4;

	switch( k_len ) {
		case 8 :
			f_nround(b1, b0, kp); f_nround(b0, b1, kp);
		case 6 :
			f_nround(b1, b0, kp); f_nround(b0, b1, kp);
		case 4 :
			f_nround(b1, b0, kp); f_nround(b0, b1, kp);
			f_nround(b1, b0, kp); f_nround(b0, b1, kp);
			f_nround(b1, b0, kp); f_nround(b0, b1, kp);
			f_nround(b1, b0, kp); f_nround(b0, b1, kp);
			f_nround(b1, b0, kp); f_lround(b0, b1, kp);
	}

	//
	LITTLE_D2B(b0[0], &(Data[ 0]));
	LITTLE_D2B(b0[1], &(Data[ 4]));
	LITTLE_D2B(b0[2], &(Data[ 8]));
	LITTLE_D2B(b0[3], &(Data[12]));
}

/*************** Function *************************************************
*	
*/
void	AES_Decrypt(
		void		*CipherKey,		//
		BYTE		*Data)			//
{
	RIJNDAEL_CIPHER_KEY	*RK_Struct=CipherKey;
	DWORD	*d_key=RK_Struct->RK;	//	64 DWORDs
	DWORD	k_len=RK_Struct->k_len;
	u4byte	b0[4], b1[4], *kp;

	LITTLE_B2D(&(Data[ 0]), b0[0]);
	LITTLE_B2D(&(Data[ 4]), b0[1]);
	LITTLE_B2D(&(Data[ 8]), b0[2]);
	LITTLE_B2D(&(Data[12]), b0[3]);

	//
	b0[0] ^= d_key[0];
	b0[1] ^= d_key[1];
	b0[2] ^= d_key[2];
	b0[3] ^= d_key[3];

	kp = d_key + 4;

	switch( k_len ) {
		case 8 :
			i_nround(b1, b0, kp); i_nround(b0, b1, kp);
		case 6 :
			i_nround(b1, b0, kp); i_nround(b0, b1, kp);
		case 4 :
			i_nround(b1, b0, kp); i_nround(b0, b1, kp);
			i_nround(b1, b0, kp); i_nround(b0, b1, kp);
			i_nround(b1, b0, kp); i_nround(b0, b1, kp);
			i_nround(b1, b0, kp); i_nround(b0, b1, kp);
			i_nround(b1, b0, kp); i_lround(b0, b1, kp);
	}

	//
	LITTLE_D2B(b0[0], &(Data[ 0]));
	LITTLE_D2B(b0[1], &(Data[ 4]));
	LITTLE_D2B(b0[2], &(Data[ 8]));
	LITTLE_D2B(b0[3], &(Data[12]));
}

/*************** END OF FILE **********************************************/


/*************** Header files *********************************************/

RET_VAL ECB_DecFinal(
                     AES_ALG_INFO	*AlgInfo,
                     BYTE		*PlainTxt,
                     DWORD		*PlainTxtLen);
RET_VAL CBC_DecFinal(
                     AES_ALG_INFO	*AlgInfo,
                     BYTE		*PlainTxt,
                     DWORD		*PlainTxtLen);
RET_VAL OFB_DecFinal(
                     AES_ALG_INFO	*AlgInfo,
                     BYTE		*PlainTxt,		
                     DWORD		*PlainTxtLen);
RET_VAL CFB_DecFinal(
                     AES_ALG_INFO	*AlgInfo,
                     BYTE		*PlainTxt,		
                     DWORD		*PlainTxtLen);
/*************** Assertions ***********************************************/

/*************** Definitions / Macros  ************************************/
#define BlockCopy(pbDst, pbSrc) {					\
((DWORD *)(pbDst))[0] = ((DWORD *)(pbSrc))[0];	\
((DWORD *)(pbDst))[1] = ((DWORD *)(pbSrc))[1];	\
((DWORD *)(pbDst))[2] = ((DWORD *)(pbSrc))[2];	\
((DWORD *)(pbDst))[3] = ((DWORD *)(pbSrc))[3];	\
}
#define BlockXor(pbDst, phSrc1, phSrc2) {			\
((DWORD *)(pbDst))[0] = ((DWORD *)(phSrc1))[0]	\
^ ((DWORD *)(phSrc2))[0];	\
((DWORD *)(pbDst))[1] = ((DWORD *)(phSrc1))[1]	\
^ ((DWORD *)(phSrc2))[1];	\
((DWORD *)(pbDst))[2] = ((DWORD *)(phSrc1))[2]	\
^ ((DWORD *)(phSrc2))[2];	\
((DWORD *)(pbDst))[3] = ((DWORD *)(phSrc1))[3]	\
^ ((DWORD *)(phSrc2))[3];	\
}

/*************** New Data Types *******************************************/

/*************** Global Variables *****************************************/

/*************** Prototypes ***********************************************/
void	AES_Encrypt(
                    void		*CipherKey,		//	��/��ȣ�� Round Key
                    BYTE		*Data);			//	������� ���� ����� ����Ű�� pointer
void	AES_Decrypt(
                    void		*CipherKey,		//	��/��ȣ�� Round Key
                    BYTE		*Data);			//	������� ���� ����� ����Ű�� pointer

/*************** Constants ************************************************/

/*************** Constants ************************************************/

/*************** Macros ***************************************************/

/*************** Global Variables *****************************************/

/*************** Function *************************************************
 *
 */
void	AES_SetAlgInfo(
                       DWORD			ModeID,
                       DWORD			PadType,
                       BYTE			*IV,
                       AES_ALG_INFO	*AlgInfo)
{
	AlgInfo->ModeID = ModeID;
	AlgInfo->PadType = PadType;
    
	if( IV!=NULL )
		memcpy(AlgInfo->IV, IV, AES_BLOCK_LEN);
	else
		memset(AlgInfo->IV, 0, AES_BLOCK_LEN);
}

/*************** Function *************************************************
 *
 */
static RET_VAL PaddSet(
                       BYTE	*pbOutBuffer,
                       DWORD	dRmdLen,
                       DWORD	dBlockLen,
                       DWORD	dPaddingType)
{
	DWORD dPadLen;
    
	switch( dPaddingType ) {
		case AI_NO_PADDING :
			if( dRmdLen==0 )	return 0;
			else				return CTR_DATA_LEN_ERROR;
            
		case AI_PKCS_PADDING :
			dPadLen = dBlockLen - dRmdLen;
			memset(pbOutBuffer+dRmdLen, (char)dPadLen, (int)dPadLen);
			return dPadLen;
            
		default :
			return CTR_FATAL_ERROR;
	}
}

/*************** Function *************************************************
 *
 */
static RET_VAL PaddCheck(
                         BYTE	*pbOutBuffer,
                         DWORD	dBlockLen,
                         DWORD	dPaddingType)
{
	DWORD i, dPadLen;
    
	switch( dPaddingType ) {
		case AI_NO_PADDING :
			return 0;			//	padding�� ����Ÿ�� 0����Ʈ��.
            
		case AI_PKCS_PADDING :
			dPadLen = pbOutBuffer[dBlockLen-1];
			if( ((int)dPadLen<=0) || (dPadLen>(int)dBlockLen) )
				return CTR_PAD_CHECK_ERROR;
			for( i=1; i<=dPadLen; i++)
				if( pbOutBuffer[dBlockLen-i] != dPadLen )
					return CTR_PAD_CHECK_ERROR;
			return dPadLen;
            
		default :
			return CTR_FATAL_ERROR;
	}
}

/**************************************************************************
 *
 */
RET_VAL	AES_EncInit(
                    AES_ALG_INFO	*AlgInfo)
{
	AlgInfo->BufLen = 0;
	if( AlgInfo->ModeID!=AI_ECB )
		memcpy(AlgInfo->ChainVar, AlgInfo->IV, AES_BLOCK_LEN);
	return CTR_SUCCESS;
}

/**************************************************************************
 *
 */
static RET_VAL ECB_EncUpdate(
                             AES_ALG_INFO	*AlgInfo,		//	
                             BYTE		*PlainTxt,		//	�ԷµǴ� ���� pointer
                             DWORD		PlainTxtLen,	//	�ԷµǴ� ���� ����Ʈ ��
                             BYTE		*CipherTxt, 	//	��ȣ���� ��µ� pointer
                             DWORD		*CipherTxtLen)	//	��µǴ� ��ȣ���� ����Ʈ ��
{
	DWORD		*ScheduledKey=AlgInfo->RoundKey;
	DWORD		BlockLen=AES_BLOCK_LEN, BufLen=AlgInfo->BufLen;
    
	//
	*CipherTxtLen = BufLen + PlainTxtLen;
    
	//	No one block
	if( *CipherTxtLen<BlockLen ) {
		memcpy(AlgInfo->Buffer+BufLen, PlainTxt, (int)PlainTxtLen);
		AlgInfo->BufLen += PlainTxtLen;
		*CipherTxtLen = 0;
		return CTR_SUCCESS;
	}
    
	//	control the case that PlainTxt and CipherTxt are the same buffer
	if( PlainTxt==CipherTxt )
		return CTR_FATAL_ERROR;
    
	//	first block
	memcpy(AlgInfo->Buffer+BufLen, PlainTxt, (int)(BlockLen - BufLen));
	PlainTxt += BlockLen - BufLen;
	PlainTxtLen -= BlockLen - BufLen;
    
	//	core part
	BlockCopy(CipherTxt, AlgInfo->Buffer);
	AES_Encrypt(ScheduledKey, CipherTxt);
	CipherTxt += BlockLen;
	while( PlainTxtLen>=BlockLen ) {
		BlockCopy(CipherTxt, PlainTxt);
		AES_Encrypt(ScheduledKey, CipherTxt);
		PlainTxt += BlockLen;
		CipherTxt += BlockLen;
		PlainTxtLen -= BlockLen;
	}
    
	//	save remained data
	memcpy(AlgInfo->Buffer, PlainTxt, (int)PlainTxtLen);
	AlgInfo->BufLen = PlainTxtLen;
	*CipherTxtLen -= PlainTxtLen;
    
	//	control the case that PlainTxt and CipherTxt are the same buffer
	return CTR_SUCCESS;
}

/**************************************************************************
 *
 */
static RET_VAL CBC_EncUpdate(
                             AES_ALG_INFO	*AlgInfo,		//	
                             BYTE		*PlainTxt,		//	�ԷµǴ� ���� pointer
                             DWORD		PlainTxtLen,	//	�ԷµǴ� ���� ����Ʈ ��
                             BYTE		*CipherTxt, 	//	��ȣ���� ��µ� pointer
                             DWORD		*CipherTxtLen)	//	��µǴ� ��ȣ���� ����Ʈ ��
{
	DWORD		*ScheduledKey=AlgInfo->RoundKey;
	DWORD		BlockLen=AES_BLOCK_LEN, BufLen=AlgInfo->BufLen;
    
	//
	*CipherTxtLen = BufLen + PlainTxtLen;
    
	//	No one block
	if( *CipherTxtLen<BlockLen ) {
		memcpy(AlgInfo->Buffer+BufLen, PlainTxt, (int)PlainTxtLen);
		AlgInfo->BufLen += PlainTxtLen;
		*CipherTxtLen = 0;
		return CTR_SUCCESS;
	}
    
	//	control the case that PlainTxt and CipherTxt are the same buffer
	if( PlainTxt==CipherTxt )
		return CTR_FATAL_ERROR;
    
	//	first block
	memcpy(AlgInfo->Buffer+BufLen, PlainTxt, (int)(BlockLen - BufLen));
	PlainTxt += BlockLen - BufLen;
	PlainTxtLen -= BlockLen - BufLen;
    
	//	core part
	BlockXor(CipherTxt, AlgInfo->ChainVar, AlgInfo->Buffer);
	AES_Encrypt(ScheduledKey, CipherTxt);
	CipherTxt += BlockLen;
	while( PlainTxtLen>=BlockLen ) {
		BlockXor(CipherTxt, CipherTxt-BlockLen, PlainTxt);
		AES_Encrypt(ScheduledKey, CipherTxt);
		PlainTxt += BlockLen;
		CipherTxt += BlockLen;
		PlainTxtLen -= BlockLen;
	}
	BlockCopy(AlgInfo->ChainVar, CipherTxt-BlockLen);
    
	//	save remained data
	memcpy(AlgInfo->Buffer, PlainTxt, (int)PlainTxtLen);
	AlgInfo->BufLen = PlainTxtLen;
	*CipherTxtLen -= PlainTxtLen;
    
	//
	return CTR_SUCCESS;
}

/**************************************************************************
 *
 */
static RET_VAL OFB_EncUpdate(
                             AES_ALG_INFO	*AlgInfo,		//	
                             BYTE		*PlainTxt,		//	�ԷµǴ� ���� pointer
                             DWORD		PlainTxtLen,	//	�ԷµǴ� ���� ����Ʈ ��
                             BYTE		*CipherTxt, 	//	��ȣ���� ��µ� pointer
                             DWORD		*CipherTxtLen)	//	��µǴ� ��ȣ���� ����Ʈ ��
{
	DWORD		*ScheduledKey=AlgInfo->RoundKey;
	DWORD		BlockLen=AES_BLOCK_LEN;
	DWORD		BufLen=AlgInfo->BufLen;
    
	//	Check Output Memory Size
	*CipherTxtLen = BufLen + PlainTxtLen;
    
	//	No one block
	if( *CipherTxtLen<BlockLen ) {
		memcpy(AlgInfo->Buffer+BufLen, PlainTxt, (int)PlainTxtLen);
		AlgInfo->BufLen += PlainTxtLen;
		*CipherTxtLen = 0;
		return CTR_SUCCESS;
	}
    
	//	control the case that PlainTxt and CipherTxt are the same buffer
	if( PlainTxt==CipherTxt )
		return CTR_FATAL_ERROR;
    
	//	first block
	memcpy(AlgInfo->Buffer+BufLen, PlainTxt, (int)(BlockLen - BufLen));
	PlainTxt += BlockLen - BufLen;
	PlainTxtLen -= BlockLen - BufLen;
    
	//	core part
	AES_Encrypt(ScheduledKey, AlgInfo->ChainVar);
	BlockXor(CipherTxt, AlgInfo->ChainVar, AlgInfo->Buffer);
	CipherTxt += BlockLen;
	while( PlainTxtLen>=BlockLen ) {
		AES_Encrypt(ScheduledKey, AlgInfo->ChainVar);
		BlockXor(CipherTxt, AlgInfo->ChainVar, PlainTxt);
		PlainTxt += BlockLen;
		CipherTxt += BlockLen;
		PlainTxtLen -= BlockLen;
	}
    
	//	save remained data
	memcpy(AlgInfo->Buffer, PlainTxt, (int)PlainTxtLen);
	AlgInfo->BufLen = (AlgInfo->BufLen&0xF0000000) + PlainTxtLen;
	*CipherTxtLen -= PlainTxtLen;
    
	//
	return CTR_SUCCESS;
}

/**************************************************************************
 *
 */
static RET_VAL CFB_EncUpdate(
                             AES_ALG_INFO	*AlgInfo,		//	
                             BYTE		*PlainTxt,		//	�ԷµǴ� ���� pointer
                             DWORD		PlainTxtLen,	//	�ԷµǴ� ���� ����Ʈ ��
                             BYTE		*CipherTxt, 	//	��ȣ���� ��µ� pointer
                             DWORD		*CipherTxtLen)	//	��µǴ� ��ȣ���� ����Ʈ ��
{
	DWORD		*ScheduledKey=AlgInfo->RoundKey;
	DWORD		BlockLen=AES_BLOCK_LEN;
	DWORD		BufLen=AlgInfo->BufLen;
    
	//	Check Output Memory Size
	*CipherTxtLen = BufLen + PlainTxtLen;
    
	//	No one block
	if( *CipherTxtLen<BlockLen ) {
		memcpy(AlgInfo->Buffer+BufLen, PlainTxt, (int)PlainTxtLen);
		AlgInfo->BufLen += PlainTxtLen;
		*CipherTxtLen = 0;
		return CTR_SUCCESS;
	}
    
	//	control the case that PlainTxt and CipherTxt are the same buffer
	if( PlainTxt==CipherTxt )
		return CTR_FATAL_ERROR;
    
	//	first block
	memcpy(AlgInfo->Buffer+BufLen, PlainTxt, (int)(BlockLen - BufLen));
	PlainTxt += BlockLen - BufLen;
	PlainTxtLen -= BlockLen - BufLen;
    
	//	core part
	AES_Encrypt(ScheduledKey, AlgInfo->ChainVar);
	BlockXor(AlgInfo->ChainVar, AlgInfo->ChainVar, AlgInfo->Buffer);
	BlockCopy(CipherTxt, AlgInfo->ChainVar);
	CipherTxt += BlockLen;
	while( PlainTxtLen>=BlockLen ) {
		AES_Encrypt(ScheduledKey, AlgInfo->ChainVar);
		BlockXor(AlgInfo->ChainVar, AlgInfo->ChainVar, PlainTxt);
		BlockCopy(CipherTxt, AlgInfo->ChainVar);
		PlainTxt += BlockLen;
		CipherTxt += BlockLen;
		PlainTxtLen -= BlockLen;
	}
    
	//	save remained data
	memcpy(AlgInfo->Buffer, PlainTxt, (int)PlainTxtLen);
	AlgInfo->BufLen = (AlgInfo->BufLen&0xF0000000) + PlainTxtLen;
	*CipherTxtLen -= PlainTxtLen;
    
	//
	return CTR_SUCCESS;
}

/**************************************************************************
 *
 */
RET_VAL	AES_EncUpdate(
                      AES_ALG_INFO	*AlgInfo,
                      BYTE		*PlainTxt,		//	�ԷµǴ� ���� pointer
                      DWORD		PlainTxtLen,	//	�ԷµǴ� ���� ����Ʈ ��
                      BYTE		*CipherTxt, 	//	��ȣ���� ��µ� pointer
                      DWORD		*CipherTxtLen)	//	��µǴ� ��ȣ���� ����Ʈ ��
{
	switch( AlgInfo->ModeID ) {
		case AI_ECB :	return ECB_EncUpdate(AlgInfo, PlainTxt, PlainTxtLen,
											 CipherTxt, CipherTxtLen);
		case AI_CBC :	return CBC_EncUpdate(AlgInfo, PlainTxt, PlainTxtLen,
											 CipherTxt, CipherTxtLen);
		case AI_OFB :	return OFB_EncUpdate(AlgInfo, PlainTxt, PlainTxtLen,
											 CipherTxt, CipherTxtLen);
		case AI_CFB :	return CFB_EncUpdate(AlgInfo, PlainTxt, PlainTxtLen,
											 CipherTxt, CipherTxtLen);
		default :		return CTR_FATAL_ERROR;
	}
}

/**************************************************************************
 *
 */
static RET_VAL ECB_EncFinal(
                            AES_ALG_INFO	*AlgInfo,		//	
                            BYTE		*CipherTxt, 	//	��ȣ���� ��µ� pointer
                            DWORD		*CipherTxtLen)	//	��µǴ� ��ȣ���� ����Ʈ ��
{
	DWORD		*ScheduledKey=AlgInfo->RoundKey;
	DWORD		BlockLen=AES_BLOCK_LEN, BufLen=AlgInfo->BufLen;
	DWORD		PaddByte;
    
	//	Padding
	PaddByte = PaddSet(AlgInfo->Buffer, BufLen, BlockLen, AlgInfo->PadType);
	if( PaddByte>BlockLen )		return PaddByte;
    
	if( PaddByte==0 ) {
		*CipherTxtLen = 0;
		return CTR_SUCCESS;
	}
    
	//	core part
	BlockCopy(CipherTxt, AlgInfo->Buffer);
	AES_Encrypt(ScheduledKey, CipherTxt);
    
	//
	*CipherTxtLen = BlockLen;
    
	//
	return CTR_SUCCESS;
}

/**************************************************************************
 *
 */
static RET_VAL CBC_EncFinal(
                            AES_ALG_INFO	*AlgInfo,
                            BYTE		*CipherTxt, 	//	��ȣ���� ��µ� pointer
                            DWORD		*CipherTxtLen)	//	��µǴ� ��ȣ���� ����Ʈ ��
{
	DWORD		*ScheduledKey=AlgInfo->RoundKey;
	DWORD		BlockLen=AES_BLOCK_LEN, BufLen=AlgInfo->BufLen;
	DWORD		PaddByte;
    
	//	Padding
	PaddByte = PaddSet(AlgInfo->Buffer, BufLen, BlockLen, AlgInfo->PadType);
	if( PaddByte>BlockLen )		return PaddByte;
    
	if( PaddByte==0 ) {
		*CipherTxtLen = 0;
		return CTR_SUCCESS;
	}
    
	//	core part
	BlockXor(CipherTxt, AlgInfo->Buffer, AlgInfo->ChainVar);
	AES_Encrypt(ScheduledKey, CipherTxt);
	BlockCopy(AlgInfo->ChainVar, CipherTxt);
    
	//
	*CipherTxtLen = BlockLen;
    
	//
	return CTR_SUCCESS;
}

/**************************************************************************
 *
 */
static RET_VAL OFB_EncFinal(
                            AES_ALG_INFO	*AlgInfo,
                            BYTE		*CipherTxt, 	//	��ȣ���� ��µ� pointer
                            DWORD		*CipherTxtLen)	//	��µǴ� ��ȣ���� ����Ʈ ��
{
	DWORD		*ScheduledKey=AlgInfo->RoundKey;
	DWORD		BlockLen=AES_BLOCK_LEN;
	DWORD		BufLen=AlgInfo->BufLen;
	DWORD		i;
    
	//	Check Output Memory Size
	*CipherTxtLen = BlockLen;
    
	//	core part
	AES_Encrypt(ScheduledKey, AlgInfo->ChainVar);
	for( i=0; i<BufLen; i++)
		CipherTxt[i] = (BYTE) (AlgInfo->Buffer[i] ^ AlgInfo->ChainVar[i]);
    
	//
	*CipherTxtLen = BufLen;
    
	//
	return CTR_SUCCESS;
}

/**************************************************************************
 *
 */
static RET_VAL CFB_EncFinal(
                            AES_ALG_INFO	*AlgInfo,
                            BYTE		*CipherTxt, 	//	��ȣ���� ��µ� pointer
                            DWORD		*CipherTxtLen)	//	��µǴ� ��ȣ���� ����Ʈ ��
{
	DWORD		*ScheduledKey=AlgInfo->RoundKey;
	DWORD		BufLen=AlgInfo->BufLen;
    
	//	Check Output Memory Size
	*CipherTxtLen = BufLen;
    
	//	core part
	AES_Encrypt(ScheduledKey, AlgInfo->ChainVar);
	BlockXor(AlgInfo->ChainVar, AlgInfo->ChainVar, AlgInfo->Buffer);
	memcpy(CipherTxt, AlgInfo->ChainVar, BufLen);
    
	//
	*CipherTxtLen = BufLen;
    
	//
	return CTR_SUCCESS;
}

/**************************************************************************
 *
 */
RET_VAL	AES_EncFinal(
                     AES_ALG_INFO	*AlgInfo,
                     BYTE		*CipherTxt, 	//	��ȣ���� ��µ� pointer
                     DWORD		*CipherTxtLen)	//	��µǴ� ��ȣ���� ����Ʈ ��
{
	switch( AlgInfo->ModeID ) {
		case AI_ECB :	return ECB_EncFinal(AlgInfo, CipherTxt, CipherTxtLen);
		case AI_CBC :	return CBC_EncFinal(AlgInfo, CipherTxt, CipherTxtLen);
		case AI_OFB :	return OFB_EncFinal(AlgInfo, CipherTxt, CipherTxtLen);
		case AI_CFB :	return CFB_EncFinal(AlgInfo, CipherTxt, CipherTxtLen);
		default :		return CTR_FATAL_ERROR;
	}
}

/**************************************************************************
 *
 */
RET_VAL	AES_DecInit(
                    AES_ALG_INFO	*AlgInfo)
{
	AlgInfo->BufLen = 0;
	if( AlgInfo->ModeID!=AI_ECB )
		memcpy(AlgInfo->ChainVar, AlgInfo->IV, AES_BLOCK_LEN);
	return CTR_SUCCESS;
}

/**************************************************************************
 *
 */
static RET_VAL ECB_DecUpdate(
                             AES_ALG_INFO	*AlgInfo,
                             BYTE		*CipherTxt, 	//	�ԷµǴ� ��ȣ���� pointer
                             DWORD		CipherTxtLen,	//	�ԷµǴ� ��ȣ���� ����Ʈ ��
                             BYTE		*PlainTxt,		//	���� ��µ� pointer
                             DWORD		*PlainTxtLen)	//	��µǴ� ���� ����Ʈ ��
{
	DWORD		*ScheduledKey=AlgInfo->RoundKey;
	DWORD		BlockLen=AES_BLOCK_LEN;
	DWORD		BufLen=AlgInfo->BufLen;
    
	//
	*PlainTxtLen = BufLen + CipherTxtLen;
    
	//	No one block
	if( BufLen+CipherTxtLen <= BlockLen ) {
		memcpy(AlgInfo->Buffer+BufLen, CipherTxt, (int)CipherTxtLen);
		AlgInfo->BufLen += CipherTxtLen;
		*PlainTxtLen = 0;
		return CTR_SUCCESS;
	}
    
	//	control the case that CipherTxt and PlainTxt are the same buffer
	if( CipherTxt==PlainTxt )	return CTR_FATAL_ERROR;
    
	//	first block
	*PlainTxtLen = BufLen + CipherTxtLen;
	memcpy(AlgInfo->Buffer+BufLen, CipherTxt, (int)(BlockLen - BufLen));
	CipherTxt += BlockLen - BufLen;
	CipherTxtLen -= BlockLen - BufLen;
    
	//	core part
	BlockCopy(PlainTxt, AlgInfo->Buffer);
	AES_Decrypt(ScheduledKey, PlainTxt);
	PlainTxt += BlockLen;
	while( CipherTxtLen>BlockLen ) {
		BlockCopy(PlainTxt, CipherTxt);
		AES_Decrypt(ScheduledKey, PlainTxt);
		CipherTxt += BlockLen;
		PlainTxt += BlockLen;
		CipherTxtLen -= BlockLen;
	}
    
	//	save remained data
	memcpy(AlgInfo->Buffer, CipherTxt, (int)CipherTxtLen);
	AlgInfo->BufLen = (AlgInfo->BufLen&0xF0000000) + CipherTxtLen;
	*PlainTxtLen -= CipherTxtLen;
    
	//
	return CTR_SUCCESS;
}

/**************************************************************************
 *
 */
static RET_VAL CBC_DecUpdate(
                             AES_ALG_INFO	*AlgInfo,
                             BYTE		*CipherTxt, 	//	�ԷµǴ� ��ȣ���� pointer
                             DWORD		CipherTxtLen,	//	�ԷµǴ� ��ȣ���� ����Ʈ ��
                             BYTE		*PlainTxt,		//	���� ��µ� pointer
                             DWORD		*PlainTxtLen)	//	��µǴ� ���� ����Ʈ ��
{
	DWORD		*ScheduledKey=AlgInfo->RoundKey;
	DWORD		BlockLen=AES_BLOCK_LEN, BufLen=AlgInfo->BufLen;
    
	//	Check Output Memory Size
	*PlainTxtLen = BufLen + CipherTxtLen;
    
	//	No one block
	if( BufLen+CipherTxtLen <= BlockLen ) {
		memcpy(AlgInfo->Buffer+BufLen, CipherTxt, (int)CipherTxtLen);
		AlgInfo->BufLen += CipherTxtLen;
		*PlainTxtLen = 0;
		return CTR_SUCCESS;
	}
    
	//	control the case that CipherTxt and PlainTxt are the same buffer
	if( CipherTxt==PlainTxt )	return CTR_FATAL_ERROR;
    
	//	first block
	*PlainTxtLen = BufLen + CipherTxtLen;
	memcpy(AlgInfo->Buffer+BufLen, CipherTxt, (int)(BlockLen - BufLen));
	CipherTxt += BlockLen - BufLen;
	CipherTxtLen -= BlockLen - BufLen;
    
	//	core part
	BlockCopy(PlainTxt, AlgInfo->Buffer);
	AES_Decrypt(ScheduledKey, PlainTxt);
	BlockXor(PlainTxt, PlainTxt, AlgInfo->ChainVar);
	PlainTxt += BlockLen;
	if( CipherTxtLen<=BlockLen ) {
		BlockCopy(AlgInfo->ChainVar, AlgInfo->Buffer);
	}
	else {
		if( CipherTxtLen>BlockLen ) {
			BlockCopy(PlainTxt, CipherTxt);
			AES_Decrypt(ScheduledKey, PlainTxt);
			BlockXor(PlainTxt, PlainTxt, AlgInfo->Buffer);
			CipherTxt += BlockLen;
			PlainTxt += BlockLen;
			CipherTxtLen -= BlockLen;
		}
		while( CipherTxtLen>BlockLen ) {
			BlockCopy(PlainTxt, CipherTxt);
			AES_Decrypt(ScheduledKey, PlainTxt);
			BlockXor(PlainTxt, PlainTxt, CipherTxt-BlockLen);
			CipherTxt += BlockLen;
			PlainTxt += BlockLen;
			CipherTxtLen -= BlockLen;
		}
		BlockCopy(AlgInfo->ChainVar, CipherTxt-BlockLen);
	}
    
	//	save remained data
	memcpy(AlgInfo->Buffer, CipherTxt, (int)CipherTxtLen);
	AlgInfo->BufLen = (AlgInfo->BufLen&0xF0000000) + CipherTxtLen;
	*PlainTxtLen -= CipherTxtLen;
    
	//
	return CTR_SUCCESS;
}

/**************************************************************************
 *
 */
static RET_VAL OFB_DecUpdate(
                             AES_ALG_INFO	*AlgInfo,
                             BYTE		*CipherTxt, 	//	�ԷµǴ� ��ȣ���� pointer
                             DWORD		CipherTxtLen,	//	�ԷµǴ� ��ȣ���� ����Ʈ ��
                             BYTE		*PlainTxt,		//	���� ��µ� pointer
                             DWORD		*PlainTxtLen)	//	��µǴ� ���� ����Ʈ ��
{
	DWORD		*ScheduledKey=AlgInfo->RoundKey;
	DWORD		BlockLen=AES_BLOCK_LEN;
	DWORD		BufLen=AlgInfo->BufLen;
    
	//	Check Output Memory Size
	*PlainTxtLen = BufLen + CipherTxtLen;
    
	//	No one block
	if( BufLen+CipherTxtLen <= BlockLen ) {
		memcpy(AlgInfo->Buffer+BufLen, CipherTxt, (int)CipherTxtLen);
		AlgInfo->BufLen += CipherTxtLen;
		*PlainTxtLen = 0;
		return CTR_SUCCESS;
	}
    
	//	control the case that CipherTxt and PlainTxt are the same buffer
	if( PlainTxt==CipherTxt )
		return CTR_FATAL_ERROR;
    
	//	first block
	*PlainTxtLen = BufLen + CipherTxtLen;
	memcpy(AlgInfo->Buffer+BufLen, CipherTxt, (int)(BlockLen - BufLen));
	CipherTxt += BlockLen - BufLen;
	CipherTxtLen -= BlockLen - BufLen;
    
	//	core part
	AES_Encrypt(ScheduledKey, AlgInfo->ChainVar);
	BlockXor(PlainTxt, AlgInfo->ChainVar, AlgInfo->Buffer);
	PlainTxt += BlockLen;
	while( CipherTxtLen>BlockLen ) {
		AES_Encrypt(ScheduledKey, AlgInfo->ChainVar);
		BlockXor(PlainTxt, AlgInfo->ChainVar, CipherTxt);
		CipherTxt += BlockLen;
		PlainTxt += BlockLen;
		CipherTxtLen -= BlockLen;
	}
    
	//	save remained data
	memcpy(AlgInfo->Buffer, CipherTxt, (int)CipherTxtLen);
	AlgInfo->BufLen = (AlgInfo->BufLen&0xF0000000) + CipherTxtLen;
	*PlainTxtLen -= CipherTxtLen;
    
	//
	return CTR_SUCCESS;
}

/**************************************************************************
 *
 */
static RET_VAL CFB_DecUpdate(
                             AES_ALG_INFO	*AlgInfo,
                             BYTE		*CipherTxt, 	//	�ԷµǴ� ��ȣ���� pointer
                             DWORD		CipherTxtLen,	//	�ԷµǴ� ��ȣ���� ����Ʈ ��
                             BYTE		*PlainTxt,		//	���� ��µ� pointer
                             DWORD		*PlainTxtLen)	//	��µǴ� ���� ����Ʈ ��
{
	DWORD		*ScheduledKey=AlgInfo->RoundKey;
	DWORD		BlockLen=AES_BLOCK_LEN;
	DWORD		BufLen=AlgInfo->BufLen;
    
	//	Check Output Memory Size
	*PlainTxtLen = BufLen + CipherTxtLen;
    
	//	No one block
	if( BufLen+CipherTxtLen <= BlockLen ) {
		memcpy(AlgInfo->Buffer+BufLen, CipherTxt, (int)CipherTxtLen);
		AlgInfo->BufLen += CipherTxtLen;
		*PlainTxtLen = 0;
		return CTR_SUCCESS;
	}
    
	//	control the case that CipherTxt and PlainTxt are the same buffer
	if( PlainTxt==CipherTxt )
		return CTR_FATAL_ERROR;
    
	//	first block
	*PlainTxtLen = BufLen + CipherTxtLen;
	memcpy(AlgInfo->Buffer+BufLen, CipherTxt, (int)(BlockLen - BufLen));
	CipherTxt += BlockLen - BufLen;
	CipherTxtLen -= BlockLen - BufLen;
    
	//	core part
	AES_Encrypt(ScheduledKey, AlgInfo->ChainVar);
	BlockXor(PlainTxt, AlgInfo->ChainVar, AlgInfo->Buffer);
	BlockCopy(AlgInfo->ChainVar, AlgInfo->Buffer);
	PlainTxt += BlockLen;
	while( CipherTxtLen>BlockLen ) {
		AES_Encrypt(ScheduledKey, AlgInfo->ChainVar);
		BlockXor(PlainTxt, AlgInfo->ChainVar, CipherTxt);
		BlockCopy(AlgInfo->ChainVar, CipherTxt);
		CipherTxt += BlockLen;
		PlainTxt += BlockLen;
		CipherTxtLen -= BlockLen;
	}
    
	//	save remained data
	memcpy(AlgInfo->Buffer, CipherTxt, (int)CipherTxtLen);
	AlgInfo->BufLen = (AlgInfo->BufLen&0xF0000000) + CipherTxtLen;
	*PlainTxtLen -= CipherTxtLen;
    
	//
	return CTR_SUCCESS;
}

/**************************************************************************
 *
 */
RET_VAL	AES_DecUpdate(
                      AES_ALG_INFO	*AlgInfo,
                      BYTE		*CipherTxt, 	//	��ȣ���� ��µ� pointer
                      DWORD		CipherTxtLen,	//	��µǴ� ��ȣ���� ����Ʈ ��
                      BYTE		*PlainTxt,		//	�ԷµǴ� ���� pointer
                      DWORD		*PlainTxtLen)	//	�ԷµǴ� ���� ����Ʈ ��
{
	switch( AlgInfo->ModeID ) {
		case AI_ECB :	return ECB_DecUpdate(AlgInfo, CipherTxt, CipherTxtLen,
											 PlainTxt, PlainTxtLen);
		case AI_CBC :	return CBC_DecUpdate(AlgInfo, CipherTxt, CipherTxtLen,
											 PlainTxt, PlainTxtLen);
		case AI_OFB :	return OFB_DecUpdate(AlgInfo, CipherTxt, CipherTxtLen,
											 PlainTxt, PlainTxtLen);
		case AI_CFB :	return CFB_DecUpdate(AlgInfo, CipherTxt, CipherTxtLen,
											 PlainTxt, PlainTxtLen);
		default :		return CTR_FATAL_ERROR;
	}
}

/**************************************************************************
 *
 */
RET_VAL ECB_DecFinal(
                     AES_ALG_INFO	*AlgInfo,
                     BYTE		*PlainTxt,		//	���� ��µ� pointer
                     DWORD		*PlainTxtLen)	//	��µǴ� ���� ����Ʈ ��
{
	DWORD		*ScheduledKey=AlgInfo->RoundKey;
	DWORD		BlockLen=AES_BLOCK_LEN, BufLen=AlgInfo->BufLen;
	RET_VAL		ret;
    
	//	Check Output Memory Size
	if( BufLen==0 ) {
		*PlainTxtLen = 0;
		return CTR_SUCCESS;
	}
	*PlainTxtLen = BlockLen;
    
	if( BufLen!=BlockLen )	return CTR_CIPHER_LEN_ERROR;
    
	//	core part
	BlockCopy(PlainTxt, AlgInfo->Buffer);
	AES_Decrypt(ScheduledKey, PlainTxt);
    
	//	Padding Check
	ret = PaddCheck(PlainTxt, BlockLen, AlgInfo->PadType);
	if( ret==(DWORD)-3 )	return CTR_PAD_CHECK_ERROR;
	if( ret==(DWORD)-1 )	return CTR_FATAL_ERROR;
    
	*PlainTxtLen = BlockLen - ret;
    
	//
	return CTR_SUCCESS;
}

/**************************************************************************
 *
 */
RET_VAL CBC_DecFinal(
                     AES_ALG_INFO	*AlgInfo,
                     BYTE		*PlainTxt,		//	���� ��µ� pointer
                     DWORD		*PlainTxtLen)	//	��µǴ� ���� ����Ʈ ��
{
	DWORD		*ScheduledKey=AlgInfo->RoundKey;
	DWORD		BlockLen=AES_BLOCK_LEN, BufLen=AlgInfo->BufLen;
	RET_VAL		ret;
    
	//	Check Output Memory Size
	if( BufLen==0 ) {
		*PlainTxtLen = 0;
		return CTR_SUCCESS;
	}
	*PlainTxtLen = BlockLen;
    
	if( BufLen!=BlockLen )	return CTR_CIPHER_LEN_ERROR;
    
	//	core part
	BlockCopy(PlainTxt, AlgInfo->Buffer);
	AES_Decrypt(ScheduledKey, PlainTxt);
	BlockXor(PlainTxt, PlainTxt, AlgInfo->ChainVar);
	BlockCopy(AlgInfo->ChainVar, AlgInfo->Buffer);
    
	//	Padding Check
	ret = PaddCheck(PlainTxt, BlockLen, AlgInfo->PadType);
	if( ret==(DWORD)-3 )	return CTR_PAD_CHECK_ERROR;
	if( ret==(DWORD)-1 )	return CTR_FATAL_ERROR;
    
	*PlainTxtLen = BlockLen - ret;
    
	//
	return CTR_SUCCESS;
}

/**************************************************************************
 *
 */
RET_VAL OFB_DecFinal(
                     AES_ALG_INFO	*AlgInfo,
                     BYTE		*PlainTxt,		//	���� ��µ� pointer
                     DWORD		*PlainTxtLen)	//	��µǴ� ���� ����Ʈ ��
{
	DWORD		*ScheduledKey=AlgInfo->RoundKey;
	DWORD		i, BufLen=AlgInfo->BufLen;
    
	//	Check Output Memory Size
	*PlainTxtLen = BufLen;
    
	//	core part
	AES_Encrypt(ScheduledKey, AlgInfo->ChainVar);
	for( i=0; i<BufLen; i++)
		PlainTxt[i] = (BYTE) (AlgInfo->Buffer[i] ^ AlgInfo->ChainVar[i]);
    
	*PlainTxtLen = BufLen;
    
	//
	return CTR_SUCCESS;
}


/**************************************************************************
 *
 */
RET_VAL CFB_DecFinal(
                     AES_ALG_INFO	*AlgInfo,
                     BYTE		*PlainTxt,		//	���� ��µ� pointer
                     DWORD		*PlainTxtLen)	//	��µǴ� ���� ����Ʈ ��
{
	DWORD		*ScheduledKey=AlgInfo->RoundKey;
	DWORD		BufLen=AlgInfo->BufLen;
    
	//	Check Output Memory Size
	*PlainTxtLen = BufLen;
    
	//	core part
	AES_Encrypt(ScheduledKey, AlgInfo->ChainVar);
	BlockXor(AlgInfo->ChainVar, AlgInfo->ChainVar, AlgInfo->Buffer);
	memcpy(PlainTxt, AlgInfo->ChainVar, BufLen);
    
	*PlainTxtLen = BufLen;
    
	//
	return CTR_SUCCESS;
}

/**************************************************************************
 *
 */
RET_VAL	AES_DecFinal(
                     AES_ALG_INFO	*AlgInfo,
                     BYTE		*PlainTxt,		//	�ԷµǴ� ���� pointer
                     DWORD		*PlainTxtLen)	//	�ԷµǴ� ���� ����Ʈ ��
{
	switch( AlgInfo->ModeID ) {
		case AI_ECB :	return ECB_DecFinal(AlgInfo, PlainTxt, PlainTxtLen);
		case AI_CBC :	return CBC_DecFinal(AlgInfo, PlainTxt, PlainTxtLen);
		case AI_OFB :	return OFB_DecFinal(AlgInfo, PlainTxt, PlainTxtLen);
		case AI_CFB :	return CFB_DecFinal(AlgInfo, PlainTxt, PlainTxtLen);
		default :		return CTR_FATAL_ERROR;
	}
}

/*************** END OF FILE **********************************************/
