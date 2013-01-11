#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

typedef unsigned int uint32_t;

int check_ppm(FILE *fp);
void *load_ppm(FILE *fp, unsigned long *xsz, unsigned long *ysz);

#if !defined(LITTLE_ENDIAN) && !defined(BIG_ENDIAN)
#if  defined(__i386__) || defined(__ia64__) || defined(WIN32) || \
    (defined(__alpha__) || defined(__alpha)) || \
     defined(__arm__) || \
    (defined(__mips__) && defined(__MIPSEL__)) || \
     defined(__SYMBIAN32__) || \
     defined(__x86_64__) || \
     defined(__LITTLE_ENDIAN__)
/* little endian */
#define LITTLE_ENDIAN
#else
/* big endian */	
#define BIG_ENDIAN
#endif	/* endian check */
#endif	/* !defined(LITTLE_ENDIAN) && !defined(BIG_ENDIAN) */

#ifdef LITTLE_ENDIAN
#define PACK_COLOR24(r, g, b) (((r & 0xff) << 16) | ((g & 0xff) << 8) | (b & 0xff))
#else
#define PACK_COLOR24(r, g, b) (((b & 0xff) << 16) | ((g & 0xff) << 8) | (r & 0xff))
#endif

void *load_image(const char *fname, unsigned long *xsz, unsigned long *ysz) {
	FILE *fp = fopen(fname, "r");
	if(!fp) {
		fprintf(stderr, "failed to open: %s\n", fname);
		return 0;
	}

	if(check_ppm(fp)) {
		return load_ppm(fp, xsz, ysz);
	}
	
	fclose(fp);
	fprintf(stderr, "unsupported image format\n");
	return 0;
}

int check_ppm(FILE *fp) {
	fseek(fp, 0, SEEK_SET);
	if(fgetc(fp) == 'P' && fgetc(fp) == '6') {
		return 1;
	}
	return 0;
}

static int read_to_wspace(FILE *fp, char *buf, int bsize) {
	int c, count = 0;
	
	while((c = fgetc(fp)) != -1 && !isspace(c) && count < bsize - 1) {
		if(c == '#') {
			while((c = fgetc(fp)) != -1 && c != '\n' && c != '\r');
			c = fgetc(fp);
			if(c == '\n' || c == '\r') continue;
		}
		*buf++ = c;
		count++;
	}
	*buf = 0;
	
	while((c = fgetc(fp)) != -1 && isspace(c));
	ungetc(c, fp);
	return count;
}

void *load_ppm(FILE *fp, unsigned long *xsz, unsigned long *ysz) {
	char buf[64];
	int bytes, raw;
	unsigned int w, h, i, sz;
	uint32_t *pixels;
	
	fseek(fp, 0, SEEK_SET);
	
	bytes = read_to_wspace(fp, buf, 64);
	raw = buf[1] == '6';

	if((bytes = read_to_wspace(fp, buf, 64)) == 0) {
		fclose(fp);
		return 0;
	}
	if(!isdigit(*buf)) {
		fprintf(fp, "load_ppm: invalid width: %s", buf);
		fclose(fp);
		return 0;
	}
	w = atoi(buf);

	if((bytes = read_to_wspace(fp, buf, 64)) == 0) {
		fclose(fp);
		return 0;
	}
	if(!isdigit(*buf)) {
		fprintf(fp, "load_ppm: invalid height: %s", buf);
		fclose(fp);
		return 0;
	}
	h = atoi(buf);

	if((bytes = read_to_wspace(fp, buf, 64)) == 0) {
		fclose(fp);
		return 0;
	}
	if(!isdigit(*buf) || atoi(buf) != 255) {
		fprintf(fp, "load_ppm: invalid or unsupported max value: %s", buf);
		fclose(fp);
		return 0;
	}

	if(!(pixels = malloc(w * h * sizeof *pixels))) {
		fputs("malloc failed", fp);
		fclose(fp);
		return 0;
	}

	sz = h * w;
	for(i=0; i<sz; i++) {
		int r = fgetc(fp);
		int g = fgetc(fp);
		int b = fgetc(fp);

		if(r == -1 || g == -1 || b == -1) {
			free(pixels);
			fclose(fp);
			fputs("load_ppm: EOF while reading pixel data", fp);
			return 0;
		}
		pixels[i] = PACK_COLOR24(r, g, b);
	}

	fclose(fp);

	if(xsz) *xsz = w;
	if(ysz) *ysz = h;
	return pixels;
}
