#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "../types.h"
#include "../external/libbmp.h"

void cropflip_asm(unsigned char *src, unsigned char *dst,
                  int src_w, int src_h,
                  int dst_w, int dst_h,
                  int offset_x, int offset_y);


typedef struct cropflip_params_t {
  int dst_width, dst_height, offsetx, offsety;
} cropflip_params_t;

cropflip_params_t extra;
void params_parser_cropflip(int argc, char *argv[], filter_config_t *config)
{
  config->extra_config = &extra;
  extra.dst_width      = atoi(argv[argc - 4]);
  extra.dst_height     = atoi(argv[argc - 3]);
  extra.offsetx        = atoi(argv[argc - 2]);
  extra.offsety        = atoi(argv[argc - 1]);

  bmp_img_init_df(&config->dst, extra.dst_width, extra.dst_height);
}

void apply_cropflip(filter_config_t* config)
{
  cropflip_params_t *extra = (cropflip_params_t *)config->extra_config;
  bmp_img* src = &config->src;
  bmp_img* dst = &config->dst;

  cropflip_asm((unsigned char*)src->img_pixels, (unsigned char*)dst->img_pixels,
               src->img_header.biWidth, src->img_header.biHeight,
               extra->dst_width, extra->dst_height,
               extra->offsetx, extra->offsety);
}