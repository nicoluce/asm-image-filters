#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "../types.h"
#include "../external/libbmp.h"

void sepia_asm(unsigned char *src, unsigned char *dst,
               int w, int h, int alpha);


typedef struct sepia_params_t {
  int alpha;
} sepia_params_t;

sepia_params_t extra;
void params_parser_sepia(int argc, char *argv[], filter_config_t *config)
{
  config->extra_config = &extra;
  extra.alpha        = atoi(argv[argc - 1]);

  bmp_img_read(&config->dst, config->input_file);
}

void apply_sepia(filter_config_t* config)
{
  sepia_params_t *extra = (sepia_params_t *)config->extra_config;
  bmp_img* src = &config->src;
  bmp_img* dst = &config->dst;

  sepia_asm((unsigned char*)src->img_pixels, (unsigned char*)dst->img_pixels,
               src->img_header.biWidth, src->img_header.biHeight,
               extra->alpha);
}