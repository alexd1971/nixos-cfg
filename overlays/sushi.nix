_final: prev: {
  sushi = prev.sushi.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../patches/sushi-no-titlebar.patch
    ];
  });
}
