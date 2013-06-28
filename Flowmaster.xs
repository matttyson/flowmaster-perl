#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <flowmaster.h>

/* A malloc like function for mortal memory */
static void*
get_mortalspace(int bytes)
{
	SV *work;
	dTHX;

	work = sv_2mortal(newSVpv("",0));
	SvGROW(work,bytes);

	return SvPVX(work);
}

/* C to Perl  */
static void
pack_float_to_perl(SV *out, float *in, int count)
{
	AV *array;
	int i;
	dTHX;

	array = (AV*) SvRV(out);
	av_clear(array);
	av_extend(array, count);

	for(i = 0; i < count; i++){
		av_store(array, i, newSVnv((double)in[i]));
	}
}

/* Perl to C  */
static void
unpack_perl_to_float(SV *in, float* out, int count)
{
	SSize_t i;
	SSize_t len;
	float *output;
	AV *array;
	SV **working;
	dTHX;

	array = (AV*) SvRV(in);
	len = av_len(array) + 1;

	for(i = 0; i < len; i++){
		working = av_fetch(array, i, 0);
		out[i] = (float) SvNV(*working);
	}

	return output;
}

/* Callback routine for reporting on the firmware flashing status */
/* Note: only one callback can be registered at a time. */
static SV *global_callback = (SV*) NULL;

static void
callback_routine(enum flash_state_e state, void *userdata, void *fmdata)
{
	dTHX;
	dSP;

	ENTER;
	SAVETMPS;
	
	PUSHMARK(SP);

	XPUSHs(sv_2mortal(newSViv(state))); /* enum state */
	XPUSHs((SV*)userdata); /* Whatever the user gave us */

	/* If it's a data type we know about, push that too */
	switch(state){
		case FLASH_BLOCK_COUNT:
		case FLASH_WRITE_BLOCK_OK:
		case FLASH_WRITE_BLOCK_ERROR:
			XPUSHs(sv_2mortal(newSViv(*(int*)fmdata)));
			break;
	}
	PUTBACK;
	call_sv(global_callback,G_DISCARD);

	FREETMPS;
	LEAVE;
}

MODULE = Flowmaster		PACKAGE = Flowmaster

TYPEMAP: <<HERE
float_array* T_PACKEDARRAY
HERE

void*
fm_create()
OUTPUT:
	RETVAL

void
fm_destroy(fm)
	void *fm

int
fm_connect(fm, port)
	void* fm
	const char* port
OUTPUT:
	RETVAL

int
fm_disconnect(fm)
	void* fm
OUTPUT:
	RETVAL

int
fm_ping(fm)
	void* fm
OUTPUT:
	RETVAL

int
fm_isconnected(fm)
	void* fm
OUTPUT:
	RETVAL

int
fm_set_fan_speed(fm, duty_cycle)
	void* fm
	float duty_cycle
OUTPUT:
	RETVAL

int
fm_set_pump_speed(fm, duty_cycle)
	void* fm
	float duty_cycle
OUTPUT:
	RETVAL

int
fm_update_status(fm)
	void* fm
OUTPUT:
	RETVAL

int
fm_set_fan_profile(fm, data)
	void* fm
	SV* data
PREINIT:
	const int profile_data_len = 65;
	float profile_data[profile_data_len];
CODE:
	unpack_perl_to_float(data, profile_data, profile_data_len);
	RETVAL = fm_set_fan_profile(fm, profile_data, profile_data_len);
OUTPUT:
	RETVAL

int
fm_get_fan_profile(fm, data)
	void* fm
	SV* data
PREINIT:
	const int profile_data_len = 65;
	float profile_data[profile_data_len];
CODE:
	RETVAL = fm_get_fan_profile(fm, profile_data, profile_data_len);
	pack_float_to_perl(data, profile_data, profile_data_len);
OUTPUT:
	data
	RETVAL

void
flash_validate_and_program(fm, filename, callback, userdata)
	void* fm
	const char* filename
	SV* callback
	SV* userdata
CODE:
	if(callback == NULL){
		flash_validate_and_program(fm, filename, NULL, NULL);
	}
	else {
		if(global_callback == NULL){
			global_callback = newSVsv(callback);
		}
		else {
			SvSetSV(global_callback, callback);
		}

		flash_validate_and_program(fm, filename, callback_routine, (void*)userdata);
	}

void
flash_validate_and_program_nocb(fm, filename)
	void* fm
	const char* filename
CODE:
	flash_validate_and_program(fm, filename, NULL, NULL);

float
fm_fan_duty_cycle(fm)
	void* fm
OUTPUT:
	RETVAL

float
fm_pump_duty_cycle(fm)
	void* fm
OUTPUT:
	RETVAL

float
fm_ambient_temp(fm)
	void* fm
OUTPUT:
	RETVAL

float
fm_coolant_temp(fm)
	void* fm
OUTPUT:
	RETVAL

int
fm_fan_rpm(fm)
	void* fm
OUTPUT:
	RETVAL

int
fm_pump_rpm(fm)
	void* fm
OUTPUT:
	RETVAL

int
fm_autoregulate(fm, state)
	void* fm
	int state
OUTPUT:
	RETVAL
